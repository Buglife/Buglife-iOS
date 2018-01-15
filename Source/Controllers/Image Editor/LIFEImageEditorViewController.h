//
//  LIFEImageEditorViewController.h
//  Copyright (C) 2018 Buglife, Inc.
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

@class LIFEAnnotatedImage;
@class LIFEImageEditorViewController;

@protocol LIFEImageEditorViewControllerDelegate <NSObject>

- (void)imageEditorViewController:(nonnull LIFEImageEditorViewController *)controller willCompleteWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage;

@optional
- (void)imageEditorViewControllerDidCancel:(nonnull LIFEImageEditorViewController *)controller;

@end

@class LIFEScreenshotContext;
@class LIFEImageEditorView;

/**
 * Replacement for LIFEScreenshotAnnotatorViewController.
 */
@interface LIFEImageEditorViewController : UIViewController

- (nonnull instancetype)initWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithScreenshot:(nonnull UIImage *)screenshot context:(nullable LIFEScreenshotContext *)context;

- (_Null_unspecified instancetype)init NS_UNAVAILABLE;
- (_Null_unspecified instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;
- (LIFEImageEditorView * _Null_unspecified)imageEditorView;

@property (nullable, nonatomic, weak) id<LIFEImageEditorViewControllerDelegate> delegate;
@property (nonatomic, getter=isInitialViewController) BOOL initialViewController;

@end
