//
//  LIFEReportWindow.h
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

@class LIFEReportWindow;
@class LIFEReportBuilder;
@class LIFEScreenshotContext;

@protocol LIFEReporterDelegate <NSObject>

- (BOOL)reporterShouldSubmitSynchronously:(nullable LIFEReportWindow *)reporter;
- (void)reporterDidCancel:(nullable LIFEReportWindow *)reporter;
- (void)reporter:(nullable LIFEReportWindow *)reporter shouldCompleteReportBuilder:(nonnull LIFEReportBuilder *)reportBuilder completion:(void (^_Nullable)(BOOL))completion;

@end

@class LIFEReportTableViewController;

typedef void (^LIFEPresentReportTableViewControllerCompletion)(LIFEReportTableViewController *__nullable);

@interface LIFEReportWindow : UIWindow

+ (nonnull instancetype)reportWindow;
// Presents the bug report window.
// The reportBuilder should NOT contain the screenshot yet!
- (void)presentReporterWithReportBuilder:(nonnull LIFEReportBuilder *)reportBuilder screenshot:(nonnull UIImage *)screenshot context:(nonnull LIFEScreenshotContext *)context simulateScreenshotCapture:(BOOL)simulateScreenshotCapture animated:(BOOL)animated;
- (void)presentReporterWithReportBuilder:(nonnull LIFEReportBuilder *)reportBuilder context:(nonnull LIFEScreenshotContext *)context animated:(BOOL)animated completion:(nullable LIFEPresentReportTableViewControllerCompletion)completion;
- (void)dismissAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;

@property (nonatomic, weak, null_unspecified) id<LIFEReporterDelegate> reporterDelegate;

@end
