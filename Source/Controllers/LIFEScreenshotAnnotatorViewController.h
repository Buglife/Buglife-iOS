//
//  LIFEScreenshotAnnotatorViewController.h
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

@class LIFEAnnotatedImage;
@class LIFEScreenshotContext;
@class LIFEScreenshotAnnotatorViewController;

@protocol LIFEScreenshotAnnotatorViewControllerDelegate <NSObject>

- (void)screenshotAnnotatorViewController:(nonnull LIFEScreenshotAnnotatorViewController *)screenshotAnnotatorViewController willCompleteWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage;

@optional
- (void)screenshotAnnotatorViewControllerDidCancel:(nonnull LIFEScreenshotAnnotatorViewController *)screenshotAnnotatorViewController;

@end

typedef NS_OPTIONS(NSInteger, LIFEChromeVisibility) {
    LIFEChromeVisibilityDefault = 0,
    LIFEChromeVisibilityHiddenForDrawing,
    LIFEChromeVisibilityHiddenViaTap, // I actually got rid of the tap gesture recognizer, so this might not be needed anymore
    LIFEChromeVisibilityHiddenForViewControllerTransition
};

@interface LIFEScreenshotAnnotatorViewController : UIViewController

@property (nonatomic, getter=isInitialViewController) BOOL initialViewController;
@property (nonatomic, weak, null_unspecified) id<LIFEScreenshotAnnotatorViewControllerDelegate> delegate;

- (nonnull instancetype)initWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithScreenshot:(nonnull UIImage *)screenshot context:(nullable LIFEScreenshotContext *)context;

- (void)setChromeVisibility:(LIFEChromeVisibility)chromeVisibility animated:(BOOL)animated completion:(nullable void (^)(void))completion;

- (_Null_unspecified instancetype)init NS_UNAVAILABLE;
- (_Null_unspecified instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;

@end
