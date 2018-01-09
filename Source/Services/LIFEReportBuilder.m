//
//  LIFEReportBuilder.m
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

#import <UIKit/UIKit.h>
#import "LIFEReportBuilder.h"
#import "LIFEReport.h"
#import "LIFEAppInfoProvider.h"
#import "LIFEDeviceInfoProvider.h"
#import "LIFELogFacility.h"
#import "LIFEMacros.h"
#import "Buglife.h"
#import "LIFEAnnotatedImage.h"
#import "LIFEReportAttachmentImpl.h"
#import "LIFEImageProcessor.h"
#import "LIFEImageFormat.h"
#import "LIFEAwesomeLogger+Protected.h"
#import "LIFEAttribute.h"
#import "LIFEVideoAttachment.h"
#import "LIFEUserFacingAttachment.h"
#import "LIFERecordingShrinker.h"
#import "LIFEUserFacingAttachment.h"
#import "NSArray+LIFEAdditions.h"

NSString * const LIFEReportBuilderAnnotatedImagesDidChangeNotification = @"com.buglife.LIFEReportBuilderAnnotatedImagesDidChangeNotification";

@interface LIFEReport (Protected)

- (instancetype)initProtected;

@end

@interface LIFEReportBuilder ()

@property (nonatomic) LIFEImageProcessor *imageProcessor;
@property (nonatomic) LIFEAppInfoProvider *appInfoProvider;
@property (nonatomic) LIFEDeviceInfoProvider *deviceInfoProvider;
@property (nonatomic) dispatch_queue_t workQueue;

@end

@implementation LIFEReportBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageProcessor = [[LIFEImageProcessor alloc] init];
        _appInfoProvider = [[LIFEAppInfoProvider alloc] init];
        _deviceInfoProvider = [[LIFEDeviceInfoProvider alloc] init];
        _workQueue = dispatch_queue_create("com.buglife.LIFEReportBuilder.workQueue", DISPATCH_QUEUE_SERIAL);
        _nonImageAttachments = @[];
        _userFacingAttachments = (NSArray<LIFEUserFacingAttachment> *)@[];
    }
    return self;
}

- (void)addAttachment:(LIFEReportAttachmentImpl *)attachment
{
    LIFEAssertMainThread;
    BOOL isImage = [self _addAttachment:attachment];
    
    if (isImage) {
        [self _postImagesDidChangeNotification];
    }
    
}

- (void)addAttachments:(NSArray<LIFEReportAttachmentImpl *> *)attachments
{
    LIFEAssertMainThread;
    BOOL hasImages = NO;

    for (LIFEReportAttachmentImpl *attachment in attachments) {
        hasImages |= [self _addAttachment:attachment];
    }
    
    if (hasImages) {
        [self _postImagesDidChangeNotification];
    }
}

// @return YES if this resulted in adding an image
- (BOOL)_addAttachment:(LIFEReportAttachmentImpl *)attachment
{
    LIFEAssertMainThread;
    
    if ([attachment isImageAttachment]) {
        UIImage *image = [UIImage imageWithData:attachment.attachmentData];
        
        if (image) {
            LIFEImageFormat imageFormat = LIFEImageFormatFromUniformTypeIdentifierAndFilename(attachment.uniformTypeIdentifier, attachment.filename);
            LIFEAnnotatedImage *annotatedImage = [[LIFEAnnotatedImage alloc] initWithSourceImage:image filename:attachment.filename format:imageFormat];
            _userFacingAttachments = (NSArray<LIFEUserFacingAttachment> *)[_userFacingAttachments arrayByAddingObject:annotatedImage];
            return YES;
        } else {
            LIFELogExtError(@"Buglife error: Unable to create image from attachment data for %@", attachment.filename);
            return NO;
        }
    } else {
        _nonImageAttachments = [_nonImageAttachments arrayByAddingObject:attachment];
        return NO;
    }
}

- (void)_postImagesDidChangeNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LIFEReportBuilderAnnotatedImagesDidChangeNotification object:nil];
}

- (void)addVideoAttachment:(LIFEVideoAttachment *)videoAttachment
{
    LIFEAssertMainThread;
    _userFacingAttachments = (NSArray<LIFEUserFacingAttachment> *)[_userFacingAttachments arrayByAddingObject:videoAttachment];
    [self _postImagesDidChangeNotification];
    
    LIFERecordingShrinker *recordingShrinker = [[LIFERecordingShrinker alloc] initWithRecording:videoAttachment];
    
    [recordingShrinker startShrinkOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) completionHandler:^(NSURL *outputURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _updateVideoAttachment:videoAttachment withVideoURL:outputURL];
        });
    }];
}

- (void)_updateVideoAttachment:(LIFEVideoAttachment *)videoAttachment withVideoURL:(NSURL *)videoURL
{
    NSInteger indexOfVideoAttachment = [self.userFacingAttachments indexOfObject:videoAttachment];
    
    if (indexOfVideoAttachment != NSNotFound) {
        LIFEVideoAttachment *updatedVideoAttachment = [[LIFEVideoAttachment alloc] initWithFileURL:videoURL uniformTypeIdentifier:videoAttachment.uniformTypeIdentifier filename:videoAttachment.filename isProcessing:NO];
        NSMutableArray<LIFEUserFacingAttachment> *userFacingAttachments = _userFacingAttachments.mutableCopy;
        userFacingAttachments[indexOfVideoAttachment] = updatedVideoAttachment;
        _userFacingAttachments = userFacingAttachments;
        [self _postImagesDidChangeNotification];
    } else {
        LIFELogIntError(@"Video file removed before we could process it");
    }
}

- (void)addAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    LIFEAssertMainThread;
    _userFacingAttachments = (NSArray<LIFEUserFacingAttachment> *)[_userFacingAttachments arrayByAddingObject:annotatedImage];
    [self _postImagesDidChangeNotification];
}

- (void)replaceAnnotatedImageAtIndex:(NSUInteger)index withAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    LIFEAssertMainThread;
    NSMutableArray<LIFEUserFacingAttachment> *userFacingAttachments = _userFacingAttachments.mutableCopy;
    userFacingAttachments[index] = annotatedImage;
    _userFacingAttachments = userFacingAttachments;
    [self _postImagesDidChangeNotification];
}

- (void)deleteAnnotatedImageAtIndex:(NSUInteger)index
{
    LIFEAssertMainThread;
    NSMutableArray<LIFEUserFacingAttachment> *userFacingAttachments = _userFacingAttachments.mutableCopy;
    [userFacingAttachments removeObjectAtIndex:index];
    _userFacingAttachments = userFacingAttachments;
}

- (void)buildReportToQueue:(dispatch_queue_t)completionQueue completion:(void (^)(LIFEReport *))completionHandler
{
    LIFEAssertMainThread;
    LIFEReport *report = [[LIFEReport alloc] initProtected];
    report.whatHappened = self.whatHappened;
    report.component = self.component;
    report.reproSteps = self.reproSteps;
    report.expectedResults = self.expectedResults;
    report.actualResults = self.actualResults;
    report.screenshot = self.screenshot;
    report.creationDate = self.creationDate;
    report.userIdentifier = self.userIdentifier;
    report.userEmail = self.userEmail;
    report.invocationMethod = self.invocationMethod;
    report.attributes = self.attributes;
    
    // Time zone
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    report.timeZoneName = timeZone.name;
    report.timeZoneAbbreviation = timeZone.abbreviation;
    
    NSMutableArray<LIFEAnnotatedImage *> *annotatedImages = [NSMutableArray array];
    NSMutableArray<LIFEVideoAttachment *> *videoAttachments = [NSMutableArray array];
    
    for (id<LIFEUserFacingAttachment> userFacingAttachment in self.userFacingAttachments) {
        if ([userFacingAttachment isKindOfClass:[LIFEAnnotatedImage class]]) {
            [annotatedImages addObject:(LIFEAnnotatedImage *)userFacingAttachment];
        } else if ([userFacingAttachment isKindOfClass:[LIFEVideoAttachment class]]) {
            [videoAttachments addObject:(LIFEVideoAttachment *)userFacingAttachment];
        } else {
            NSAssert(NO, @"Unexpected type: %@", userFacingAttachment);
        }
    }

    [[LIFEAwesomeLogger sharedLogger] asyncFlushLogsAndGetArchivedLogDataWithCompletion:^(NSData *archivedLogData) {
        NSArray<LIFEReportAttachmentImpl *> *nonImageAttachments = self.nonImageAttachments;
        
        if (archivedLogData) {
            LIFEReportAttachmentImpl *logAttachment = [[LIFEReportAttachmentImpl alloc] initWithLogData:archivedLogData];
            nonImageAttachments = [self.nonImageAttachments arrayByAddingObject:logAttachment];
        }
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(_workQueue, ^{
            __strong LIFEReportBuilder *strongSelf = weakSelf;
            if (strongSelf) {
                // "Flatten" the annotated images
                NSArray<LIFEReportAttachmentImpl *> *imageAttachments = [LIFEReportBuilder _flattenedImageAttachmentsFromAnnotatedImages:annotatedImages usingImageProcessor:self.imageProcessor];
                
                NSMutableArray<LIFEReportAttachmentImpl *> *allAttachments = [nonImageAttachments arrayByAddingObjectsFromArray:imageAttachments].mutableCopy;
                
                for (LIFEVideoAttachment *videoAttachment in videoAttachments) {
                    NSData *data = [NSData dataWithContentsOfURL:videoAttachment.url];
                    LIFEReportAttachmentImpl *videoAttachmentImpl = [[LIFEReportAttachmentImpl alloc] initWithData:data uniformTypeIdentifier:videoAttachment.uniformTypeIdentifier filename:videoAttachment.filename];
                    [allAttachments addObject:videoAttachmentImpl];
                }
                
                report.attachments = allAttachments;
                
                LIFEAppInfoProvider *appInfoProvider = self.appInfoProvider;
                
                [strongSelf.deviceInfoProvider fetchDeviceInfoToQueue:strongSelf.workQueue completion:^(LIFEDeviceInfo *deviceInfo, LIFEAttributes *systemAttributes) {
                    report.appInfo = [appInfoProvider syncFetchAppInfo];
                    report.deviceInfo = deviceInfo;
                    
                    LIFEMutableAttributes *attributes = report.attributes.mutableCopy;
                    [attributes addEntriesFromDictionary:systemAttributes];
                    report.attributes = attributes.copy;
                    
                    dispatch_async(completionQueue, ^{
                        completionHandler(report);
                    });
                }];
            }
        });
    }];
}

static const CGFloat kJPEGCompressionQuality = 0.8;
static const CGFloat kMaximumImageFilesize = 1000 * 1000 * 2; // 2 MB

+ (NSArray<LIFEReportAttachmentImpl *> *)_flattenedImageAttachmentsFromAnnotatedImages:(NSArray<LIFEAnnotatedImage *> *)annotatedImages usingImageProcessor:(LIFEImageProcessor *)imageProcessor
{
    NSMutableArray<LIFEReportAttachmentImpl *> *attachments = [NSMutableArray array];
    
    for (LIFEAnnotatedImage *annotatedImage in annotatedImages) {
        CGSize targetSize = annotatedImage.sourceImage.size;
        UIImage *flattenedImage = [imageProcessor syncGetFlattenedScaledImageForAnnotatedImage:annotatedImage targetSize:targetSize];
        NSData *imageData = LIFEImageRepresentationWithImageFormatAndMaximumSize(annotatedImage.imageFormat, flattenedImage, kJPEGCompressionQuality, kMaximumImageFilesize);
        
        if (imageData) {
            NSString *uti = LIFEImageFormatToImageUniformTypeIdentifier(annotatedImage.imageFormat);
            LIFEReportAttachmentImpl *attachment = [[LIFEReportAttachmentImpl alloc] initWithData:imageData uniformTypeIdentifier:uti filename:annotatedImage.filename];
            [attachments addObject:attachment];
        } else {
            LIFELogExtError(@"Buglife error: Unable to get image data from %@", annotatedImage.filename);
        }
    }
    
    return [NSArray arrayWithArray:attachments];
}

@end

@implementation LIFEReport (Protected)

- (instancetype)initProtected
{
    self = [super init];
    return self;
}

@end
