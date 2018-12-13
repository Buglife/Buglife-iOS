//
//  LIFEImagePickerController.m
//  Copyright (C) 2017 Buglife, Inc.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//       http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

#import "LIFEImagePickerController.h"
#import "LIFECompatibilityUtils.h"
#import "Buglife+Protected.h"
#import "LIFEMacros.h"
#import "LIFEDependencyLoader.h"
//#import <AssetsLibrary/AssetsLibrary.h>
//#import <Photos/Photos.h>

// This is actually an Apple-defined string, but I don't know if they have a key for it (it's a string used as a key in an app's info.plist)
static NSString * const LIFENSPhotoLibraryUsageDescriptionKey = @"NSPhotoLibraryUsageDescription";
static const UIImagePickerControllerSourceType kDefaultSourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
static let kLIFEUTTypeImage = @"public.image"; // Equivalent to kUTTypeImage. We redeclare this so we don't have to link MobileCoreServices.
static let kLIFEUTTypeVideo = @"public.video"; // Equivalent to kUTTypeVideo. We redeclare this so we don't have to link MobileCoreServices.
static let kLIFEUTTypeMovie = @"public.movie"; // Equivalent to kUTTypeMovie. We redeclare this so we don't have to link MobileCoreServices.

@interface LIFEImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@protocol LIFEPHFetchOptions <NSObject>
- (void)setSortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors;
- (void)setPredicate:(NSPredicate *)predicate;
@end

@protocol LIFEPHPhotoLibrary <NSObject>
+ (LIFE_PHAuthorizationStatus)authorizationStatus;
+ (void)requestAuthorization:(LIFE_PHAuthorizationStatusHandler)handler;
@end

@protocol LIFEPHFetchResult <NSFastEnumeration>
- (id)lastObject;
- (id)firstObject;
@end

@protocol LIFEPHAssetCollection <NSObject>
+ (NSObject<LIFEPHFetchResult> *)fetchAssetCollectionsWithType:(NSInteger)type subtype:(NSInteger)subtype options:(NSObject *)options;
- (NSObject<LIFEPHFetchResult> *)lastObject;
@end

@protocol LIFEPHAssetResource <NSObject>
- (NSString *)uniformTypeIdentifier;
- (NSString *)originalFilename;
@end

@protocol LIFEPHAsset <NSObject>
+ (NSObject<LIFEPHFetchResult> *)fetchAssetsInAssetCollection:(NSObject<LIFEPHAssetCollection> *)assetCollection options:(NSObject<LIFEPHFetchOptions> *)options;
// For newly recorded screen recording videos, the modificationDate is NOT equal to the creationDate;
// rather, the creationDate is roughly when the video started recording, and the modificationDate is when
// recording ended
- (NSDate *)creationDate;
- (NSDate *)modificationDate;
@end

@protocol LIFEPHImageManager <NSObject>
+ (instancetype)defaultManager;
- (int32_t)requestAVAssetForVideo:(NSObject<LIFEPHAsset> *)asset options:(nullable NSObject *)options resultHandler:(void (^)(NSObject *__nullable asset, NSObject *__nullable audioMix, NSDictionary *__nullable info))resultHandler;
@end

@protocol LIFEPHClassMethods <NSObject>
+ (NSObject<LIFEPHFetchResult> *)fetchAssetsWithALAssetURLs:(NSArray<NSURL *> *)assetURLs options:(NSObject *)options;
+ (NSArray *)assetResourcesForAsset:(NSObject *)asset;
@end

@implementation LIFEImagePickerController

#pragma mark - Public methods

static const NSInteger kLIFEImagePickerControllerRecentVideoSearchAttemptCount = 5;
static const NSTimeInterval kLIFEImagePickerControllerRecentVideoSearchSinceSecondsAgo = 60.0;
static const NSTimeInterval kLIFEImagePickerControllerRecentVideoRetryInterval = 1.0;

+ (void)getRecentVideoToQueue:(dispatch_queue_t)completionQueue withCompletion:(void (^)(NSURL *__nullable url, NSString *__nullable filename, NSString *__nullable uniformTypeIdentifier))completionHandler
{
    [self _getRecentVideoWithRemainingAttempts:kLIFEImagePickerControllerRecentVideoSearchAttemptCount toQueue:completionQueue withCompletion:completionHandler];
}

// Sometimes the screen recording notification is received, but the asset hasn't yet been saved to the
// photos database. (This appears to be an iOS bug.)
// To mitigate this, we need to retry a certain number of times just in case.
+ (void)_getRecentVideoWithRemainingAttempts:(NSInteger)remainingAttempts toQueue:(dispatch_queue_t)completionQueue withCompletion:(void (^)(NSURL *__nullable url, NSString *__nullable filename, NSString *__nullable uniformTypeIdentifier))completionHandler
{
    LIFELogIntDebug(@"LIFEImagePickerController remaining attempts: %ld", (long)remainingAttempts);
    
    if (remainingAttempts <= 0) {
        LIFELogExtDebug(@"  LIFEImagePickerController was unable to find the recent screen recording. Note that Buglife only searches for videos created within the last %.0f seconds, so this may have occurred if you were paused in the debugger.", kLIFEImagePickerControllerRecentVideoSearchSinceSecondsAgo);
        dispatch_async(completionQueue, ^{
            completionHandler(nil, nil, nil);
        });
    } else {
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-kLIFEImagePickerControllerRecentVideoSearchSinceSecondsAgo];
        [self _getLastVideoThatFinishedRecordingAfter:startDate toQueue:completionQueue withCompletion:^(NSURL * _Nullable url, NSString * _Nullable filename, NSString * _Nullable uniformTypeIdentifier) {
            if (url != nil && filename != nil && uniformTypeIdentifier != nil) {
                dispatch_async(completionQueue, ^{
                    completionHandler(url, filename, uniformTypeIdentifier);
                });
            } else {
                LIFELogIntDebug(@"  LIFEImagePickerController did not find video, retrying...");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kLIFEImagePickerControllerRecentVideoRetryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSInteger newRemainingAttempts = remainingAttempts - 1;
                    [self _getRecentVideoWithRemainingAttempts:newRemainingAttempts toQueue:completionQueue withCompletion:completionHandler];
                });
            }
        }];
    }
    
}

+ (void)_getLastVideoThatFinishedRecordingAfter:(nonnull NSDate *)minimumFinishedRecordingDate toQueue:(dispatch_queue_t)completionQueue withCompletion:(void (^)(NSURL *__nullable url, NSString *__nullable filename, NSString *__nullable uniformTypeIdentifier))completionHandler
{
    Class phAssetCollectionClass = NSClassFromString(@"PHAssetCollection");
    
    if (phAssetCollectionClass && [phAssetCollectionClass respondsToSelector:@selector(fetchAssetCollectionsWithType:subtype:options:)]) {
        NSInteger type = 2; // PHAssetCollectionTypeSmartAlbum
        NSInteger subtype = 202; // PHAssetCollectionSubtypeSmartAlbumVideos
        NSObject<LIFEPHAssetCollection> *collections = (NSObject<LIFEPHAssetCollection> *)[phAssetCollectionClass fetchAssetCollectionsWithType:type subtype:subtype options:nil];
        NSObject<LIFEPHAssetCollection> *videos = (NSObject<LIFEPHAssetCollection> *)collections.lastObject;
        
        Class phFetchOptionsClass = NSClassFromString(@"PHFetchOptions");
        
        if (phFetchOptionsClass) {
            NSObject<LIFEPHFetchOptions> *fetchOptions = [[phFetchOptionsClass alloc] init];
            // For screen recordings, the modificationDate is when it actually finished recording
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modificationDate > %@", minimumFinishedRecordingDate];
            [fetchOptions setPredicate:predicate];
            [fetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]]];
            
            Class phAssetClass = NSClassFromString(@"PHAsset");
            
            if (phAssetClass) {
                NSObject<LIFEPHFetchResult> *fetchResult = (NSObject<LIFEPHFetchResult> *)[phAssetClass fetchAssetsInAssetCollection:videos options:fetchOptions];
                
                if (fetchResult) {
                    NSObject<LIFEPHAssetCollection> *phAsset = fetchResult.firstObject;
                    
                    Class phImageManagerClass = NSClassFromString(@"PHImageManager");
                    
                    if (phImageManagerClass) {
                        [[phImageManagerClass defaultManager] requestAVAssetForVideo:(NSObject<LIFEPHAsset> *)phAsset options:nil resultHandler:^(NSObject *asset, NSObject *audioMix, NSDictionary *info) {
                            NSURL *assetUrl = nil;
                            __block NSString *filename = nil;
                            __block NSString *uniformTypeIdentifier = nil;
                            
                            if ([asset respondsToSelector:@selector(URL)]) {
                                NSObject<LIFEAVURLAsset> *urlAsset = (NSObject<LIFEAVURLAsset> *)asset;
                                assetUrl = urlAsset.URL;
                                
                                [self _syncGetMetadataForAssetURL:assetUrl resultBlock:^(NSString *fn, NSString *uti) {
                                    filename = fn;
                                    uniformTypeIdentifier = LIFEAVFileTypeMPEG4; // Force this because we can't get the UTI
                                }];
                            }
                            
                            dispatch_async(completionQueue, ^{
                                completionHandler(assetUrl, filename, uniformTypeIdentifier);
                            });
                        }];
                    }
                } else {
                    LIFELogExtError(@"LIFEImagePickerController received nil fetchResult");
                }
            }
        }
    }
}

- (void)tryPresentImagePickerControllerAnimated:(BOOL)animated didPresentHandler:(void (^)(BOOL didPresent))didPresent
{
    LIFE_PHAuthorizationStatus status = [self _authorizationStatus];
    
    switch (status) {
        case LIFE_PHAuthorizationStatusNotDetermined: {
            __weak typeof(self) weakSelf = self;
            [LIFEImagePickerController requestAuthorization:^(LIFE_PHAuthorizationStatus status) {
                NSParameterAssert([NSThread isMainThread]);
                __strong LIFEImagePickerController *strongSelf = weakSelf;
                
                if (strongSelf) {
                    if (status == LIFE_PHAuthorizationStatusAuthorized) {
                        [strongSelf _forcePresentImagePickerControllerAnimated:animated];
                        didPresent(YES);
                    } else {
                        didPresent(NO);
                    }
                }
            }];
            break;
        }
        default: {
            // Even if auth status is denied, presenting it will show the system "denied" view
            [self _forcePresentImagePickerControllerAnimated:animated];
            didPresent(YES);
            break;
        }
    }
}

- (void)_forcePresentImagePickerControllerAnimated:(BOOL)animated
{
    NSParameterAssert([NSThread isMainThread]);
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    let sourceType = kDefaultSourceType;
    imagePickerController.sourceType = sourceType;
    imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self._presentingViewController presentViewController:imagePickerController animated:animated completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    BOOL didPickUnsupportedContentType = NO;
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:kLIFEUTTypeImage]) {
        [self _didSelectImageWithInfo:info];
    } else if ([mediaType isEqualToString:kLIFEUTTypeVideo] || [mediaType isEqualToString:kLIFEUTTypeMovie]) {
        [self _didSelectVideoWithInfo:info];
    } else {
        didPickUnsupportedContentType = YES;
    }
    
    __strong typeof(self.delegate) delegate = self.delegate;
    
    [self._presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (didPickUnsupportedContentType) {
            [delegate imagePickerContrllerDidPickUnsupportedContentType:self];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self._presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Availability

- (BOOL)isImagePickerAvailable
{
    if ([UIImagePickerController isSourceTypeAvailable:kDefaultSourceType]) {
        if ([self isPhotoLibraryUsageDescriptionRequiredAndMissing]) {
            return NO;
        } else {
            return YES;
        }
    }
    
    return NO;
}

// iOS 10 requries an info.plist key to be set to access the photo library.
// This method returns YES if the key is required, but missing.
- (BOOL)isPhotoLibraryUsageDescriptionRequiredAndMissing
{
    if ([LIFECompatibilityUtils isiOS10OrHigher]) {
        NSString *usageDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:LIFENSPhotoLibraryUsageDescriptionKey];
        
        if (usageDescription == nil) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Private methods

- (UIViewController *)_presentingViewController
{
    NSParameterAssert(self.delegate);
    return [self.delegate presentingViewControllerForImagePickerController:self];
}

- (void)_didSelectImageWithInfo:(NSDictionary<NSString *, id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
    __block NSString *filename;
    __block NSString *uniformTypeIdentifier;
    
    [self _syncGetMetadataForAssetURL:assetURL resultBlock:^(NSString *fn, NSString *uti) {
        filename = fn;
        uniformTypeIdentifier = uti;
    }];

    [self.delegate imagePickerController:self didFinishPickingImage:image withFilename:filename uniformTypeIdentifier:uniformTypeIdentifier];
}

- (void)_didSelectVideoWithInfo:(NSDictionary<NSString *, id> *)info
{
    NSURL *url = info[UIImagePickerControllerMediaURL];
    NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
    __block NSString *filename;
    __block NSString *uniformTypeIdentifier;
    
    [self _syncGetMetadataForAssetURL:assetURL resultBlock:^(NSString *fn, NSString *uti) {
        filename = fn;
        uniformTypeIdentifier = uti;
    }];
    
    [self.delegate imagePickerController:self didFinishPickingVideoWithMediaURL:url withFilename:filename uniformTypeIdentifier:uniformTypeIdentifier];
}

//- (void)_syncGetMetadataForAssetURL:(NSURL *)assetURL resultBlock:(void (^)(NSString *filename, NSString *uniformTypeIdentifier))resultBlock
//{
//    NSString *filename = [assetURL lastPathComponent]; // Fallback
//    NSString *uniformTypeIdentifier = LIFEAttachmentTypeIdentifierImage;
//    NSArray *urls = @[assetURL];
//    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:urls options:nil];
//    NSAssert(fetchResult.count == 1, @"Photos framework should only return exactly 1 result for a given asset URL");
//    
//    PHAsset *asset = fetchResult.lastObject;
//    
//    if (asset) {
//        NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
//        PHAssetResource *resource = resources.firstObject;
//        NSAssert(resource != nil, @"Unable to fetch PHAssetResource for asset");
//        
//        if (resource) {
//            // Success!
//            uniformTypeIdentifier = resource.uniformTypeIdentifier;
//            filename = resource.originalFilename;
//        }
//    } else {
//        LIFELogExtWarn(@"Buglife warning: Unable to get filename for asset URL: %@", assetURL);
//    }
//    
//    resultBlock(filename, uniformTypeIdentifier);
//}

- (LIFE_PHAuthorizationStatus)_authorizationStatus
{
    LIFELoadPhotosFramework();
    
    Class phPhotoLibraryClass = NSClassFromString(@"PHPhotoLibrary");
    
    if (phPhotoLibraryClass) {
        if ([phPhotoLibraryClass respondsToSelector:@selector(authorizationStatus)]) {
            return [phPhotoLibraryClass authorizationStatus];
        } else {
            LIFELogExtError(@"Buglife error: Internal error (107). Please report this!");
        }
    } else {
        LIFELogExtWarn(@"Buglife warning: Photos.framework isn't linked, but we'll do our best to attach assets when requested! (Error 106)");
    }
    
    return LIFE_PHAuthorizationStatusNotDetermined;
}

+ (void)requestAuthorization:(LIFE_PHAuthorizationStatusHandler)handler
{
    LIFELoadPhotosFramework();
    
    Class phPhotoLibraryClass = NSClassFromString(@"PHPhotoLibrary");
    
    if (phPhotoLibraryClass) {
        if ([phPhotoLibraryClass respondsToSelector:@selector(requestAuthorization:)]) {
            [phPhotoLibraryClass requestAuthorization:^(LIFE_PHAuthorizationStatus status) {
                // Photos framework doesn't return on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(status);
                });
            }];
            return;
        } else {
            LIFELogExtError(@"Buglife error: Internal error (108). Please report this!");
        }
    } else {
        LIFELogExtWarn(@"Buglife warning: Photos.framework isn't linked, but we'll do our best to attach assets when requested! (Error 106)");
    }
    
    handler(LIFE_PHAuthorizationStatusNotDetermined);
}

- (void)_syncGetMetadataForAssetURL:(NSURL *)assetURL resultBlock:(void (^)(NSString *filename, NSString *uniformTypeIdentifier))resultBlock
{
    [[self class] _syncGetMetadataForAssetURL:assetURL resultBlock:resultBlock];
}

+ (void)_syncGetMetadataForAssetURL:(NSURL *)assetURL resultBlock:(void (^)(NSString *filename, NSString *uniformTypeIdentifier))resultBlock
{
    LIFELoadPhotosFramework();
    
    NSString *filename = [assetURL lastPathComponent]; // Fallback
    NSString *uniformTypeIdentifier = LIFEAttachmentTypeIdentifierImage;
    NSArray *urls = @[assetURL];
    
    Class phAssetClass = NSClassFromString(@"PHAsset");
    Class phAssetResourceClass = NSClassFromString(@"PHAssetResource");
    
    if (phAssetClass && phAssetResourceClass) {
        if ([phAssetClass respondsToSelector:@selector(fetchAssetsWithALAssetURLs:options:)]) {
            NSObject<LIFEPHFetchResult> *fetchResult = [phAssetClass fetchAssetsWithALAssetURLs:urls options:nil];
            
            if ([fetchResult respondsToSelector:@selector(lastObject)]) {
                NSObject *asset = [fetchResult lastObject];
                
                if (asset) {
                    if ([phAssetResourceClass respondsToSelector:@selector(assetResourcesForAsset:)]) {
                        NSArray *resources = [phAssetResourceClass assetResourcesForAsset:asset];
                        NSObject<LIFEPHAssetResource> *resource = resources.firstObject;
                        
                        if (resource) {
                            // Success!
                            uniformTypeIdentifier = resource.uniformTypeIdentifier;
                            filename = resource.originalFilename;
                        } else {
                            LIFELogExtError(@"Buglife error: Internal error attaching image asset (105). Please report this!");
                        }
                    } else {
                        LIFELogExtError(@"Buglife error: Internal error attaching image asset (104). Please report this!");
                    }
                }
            } else {
                LIFELogExtError(@"Buglife error: Internal error attaching image asset (102). Please report this!");
            }
        } else {
            LIFELogExtError(@"Buglife error: Internal error attaching image asset (101). Please report this!");
        }
    } else {
        LIFELogExtWarn(@"Buglife warning: Photos.framework isn't linked, but we'll do our best to attach assets when requested!");
    }

    resultBlock(filename, uniformTypeIdentifier);
}

@end
