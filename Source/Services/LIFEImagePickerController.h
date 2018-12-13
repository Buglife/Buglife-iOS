//
//  LIFEImagePickerController.h
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

#import <Foundation/Foundation.h>

@class UIViewController;
@class UIImage;
@class LIFEImagePickerController;

@protocol LIFEImagePickerControllerDelegate <NSObject>

- (nonnull UIViewController *)presentingViewControllerForImagePickerController:(nonnull LIFEImagePickerController *)imagePickerController;

- (void)imagePickerController:(nonnull LIFEImagePickerController *)picker didFinishPickingImage:(nonnull UIImage *)image withFilename:(nonnull NSString *)filename uniformTypeIdentifier:(nonnull NSString *)uniformTypeIdentifier;

- (void)imagePickerController:(nonnull LIFEImagePickerController *)picker didFinishPickingVideoWithMediaURL:(nonnull NSURL *)mediaURL withFilename:(nonnull NSString *)filename uniformTypeIdentifier:(nonnull NSString *)uniformTypeIdentifier;

- (void)imagePickerContrllerDidPickUnsupportedContentType:(nonnull LIFEImagePickerController *)picker;

@end

typedef NS_ENUM(NSUInteger, LIFE_PHAuthorizationStatus) {
    LIFE_PHAuthorizationStatusNotDetermined = 0,
    LIFE_PHAuthorizationStatusRestricted = 1,
    LIFE_PHAuthorizationStatusDenied = 2,
    LIFE_PHAuthorizationStatusAuthorized = 3
};

typedef void (^LIFE_PHAuthorizationStatusHandler)(LIFE_PHAuthorizationStatus);

@interface LIFEImagePickerController : NSObject

@property (nonatomic, weak, nullable) id<LIFEImagePickerControllerDelegate> delegate;

+ (void)getRecentVideoToQueue:(nonnull dispatch_queue_t)completionQueue withCompletion:(void (^_Nonnull)(NSURL *__nullable url, NSString *__nullable filename, NSString *__nullable uniformTypeIdentifier))completionHandler;

/**
 The didPresent handler lets the table view controller know if a view controller was presented,
 so that if no view controller was presented we can immediately deselect the table view row
 */
- (void)tryPresentImagePickerControllerAnimated:(BOOL)animated didPresentHandler:(void (^_Nonnull)(BOOL didPresent))handler;

+ (void)requestAuthorization:(LIFE_PHAuthorizationStatusHandler _Nonnull)handler;

#pragma mark - Availability

- (BOOL)isImagePickerAvailable;
- (BOOL)isPhotoLibraryUsageDescriptionRequiredAndMissing;

@end
