//
//  LIFEReportWindow.m
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

#import "LIFEReportWindow.h"
#import "LIFENavigationController.h"
#import "LIFEScreenshotAnnotatorViewController.h"
#import "LIFEReportTableViewController.h"
#import "LIFEReportViewControllerDelegate.h"
#import "LIFEReportBuilder.h"
#import "LIFEScreenshotContext.h"

static const CGFloat kReportWindowLevel = 999;
static const NSTimeInterval kSimulatedScreenshotAnimationDuration = 1.0;

@interface LIFEEmtpyViewController : UIViewController

@property (nonatomic) LIFEScreenshotContext *screenshotContext;

@end

@interface LIFEReportWindow () <LIFEReportViewControllerDelegate, LIFEScreenshotAnnotatorViewControllerDelegate>

@property (nonatomic, weak) LIFEEmtpyViewController *emptyViewController; // The view controller that is initially being presented
@property (nonatomic) LIFEScreenshotContext *screenshotContext;
@property (nonatomic) LIFEReportBuilder *reportBuilder;
@property (nonatomic) UIViewController *presentedViewController;
@property (nonatomic) UIViewController *realRootViewController;

@end

@implementation LIFEReportWindow

#pragma mark - Public methods

+ (instancetype)reportWindow
{
    LIFEReportWindow *reportWindow = [[LIFEReportWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    LIFEEmtpyViewController *emptyViewController = [[LIFEEmtpyViewController alloc] init];
    reportWindow.rootViewController = emptyViewController;
    reportWindow.emptyViewController = emptyViewController;
    
    reportWindow.windowLevel = kReportWindowLevel;
    return reportWindow;
}

- (void)presentReporterWithReportBuilder:(LIFEReportBuilder *)reportBuilder screenshot:(UIImage *)screenshot context:(LIFEScreenshotContext *)context simulateScreenshotCapture:(BOOL)simulateScreenshotCapture animated:(BOOL)animated
{
    self.screenshotContext = context;
    self.emptyViewController.screenshotContext = context;
    self.reportBuilder = reportBuilder;
    [self makeKeyAndVisible];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _presentReporterWithScreenshot:screenshot context:context simulateScreenshotCapture:simulateScreenshotCapture animated:animated];
    });
}

- (void)presentReporterWithReportBuilder:(LIFEReportBuilder *)reportBuilder context:(LIFEScreenshotContext *)context animated:(BOOL)animated completion:(LIFEPresentReportTableViewControllerCompletion)completion
{
    self.screenshotContext = context;
    self.emptyViewController.screenshotContext = context;
    self.reportBuilder = reportBuilder;
    [self makeKeyAndVisible];
    
    // The dispatch_async is an ugly hack that works around the
    // "The unbalanced calls to begin/end appearance transitions" bug :-/
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _presentReportTableViewControllerAnimated:animated context:context completion:completion];
    });
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    [self.presentedViewController.presentingViewController dismissViewControllerAnimated:animated completion:completion];
    self.presentedViewController = nil;
}

#pragma mark - Private methods

- (void)_presentReporterWithScreenshot:(UIImage *)screenshot context:(LIFEScreenshotContext *)context simulateScreenshotCapture:(BOOL)simulateScreenshotCapture animated:(BOOL)animated
{
    if (screenshot) {
        LIFEScreenshotAnnotatorViewController *vc = [[LIFEScreenshotAnnotatorViewController alloc] initWithScreenshot:screenshot context:context];
        vc.delegate = self;
        vc.initialViewController = YES;
        LIFENavigationController *nav = [[LIFENavigationController alloc] initWithRootViewController:vc];
        self.presentedViewController = nav;
        
        // don't animate, since we want the transition to be "seamless" from the actual app to the screenshot of the app
        [self _presentViewController:nav animated:NO completion:^{
            
            // the last thing we'll do is set the chrome to be visible
            void (^setChromeVisibilityBlock)(void) = ^{
                [vc setChromeVisibility:LIFEChromeVisibilityDefault animated:YES completion:NULL];
            };
            
            // before we set the chrome to be visible, simulate a screenshot capture (if needed)
            if (simulateScreenshotCapture) {
                [self _simulateScreenshotCaptureWithCompletion:setChromeVisibilityBlock];
            } else {
                setChromeVisibilityBlock();
            }
        }];
    }
}

- (void)_presentReportTableViewControllerAnimated:(BOOL)animated context:(LIFEScreenshotContext *)context completion:(LIFEPresentReportTableViewControllerCompletion)completion
{
    LIFEReportTableViewController *reportViewController = [[LIFEReportTableViewController alloc] initWithReportBuilder:self.reportBuilder context:context];
    reportViewController.delegate = self;
    
    self.presentedViewController = [[LIFENavigationController alloc] initWithRootViewController:reportViewController];
    [self _presentViewController:self.presentedViewController animated:animated completion:^{
        if (completion) {
            completion(reportViewController);
        }
    }];
}

- (void)_simulateScreenshotCaptureWithCompletion:(nonnull void (^)(void))completion
{
    UIView *whiteScreenshotCaptureView = [[UIView alloc] initWithFrame:self.bounds];
    whiteScreenshotCaptureView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteScreenshotCaptureView];
    
    [UIView animateWithDuration:kSimulatedScreenshotAnimationDuration animations:^{
        whiteScreenshotCaptureView.alpha = 0;
    } completion:^(BOOL finished) {
        [whiteScreenshotCaptureView removeFromSuperview];
        completion();
    }];
}

#pragma mark - VC presentation / dismissal

- (void)_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion
{
    [self.rootViewController presentViewController:viewControllerToPresent animated:animated completion:completion];
}

#pragma mark - LIFEReportViewControllerDelegate

- (BOOL)reportViewControllerShouldSubmitSynchronously:(nonnull LIFEReportTableViewController *)reportViewController
{
    return [self.reporterDelegate reporterShouldSubmitSynchronously:self];
}

- (void)reportViewControllerDidCancel:(LIFEReportTableViewController *)reportViewController
{
    [self.reporterDelegate reporterDidCancel:self];
}

- (void)reportViewController:(LIFEReportTableViewController *)reportViewController shouldCompleteReportBuilder:(LIFEReportBuilder *)reportBuilder completion:(void (^)(BOOL))completion
{
    [self.reporterDelegate reporter:self shouldCompleteReportBuilder:reportBuilder completion:completion];
}

#pragma mark - LIFEScreenshotAnnotatorViewControllerDelegate

- (void)screenshotAnnotatorViewController:(nonnull LIFEScreenshotAnnotatorViewController *)screenshotAnnotatorViewController willCompleteWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage
{
    [self.reportBuilder addAnnotatedImage:annotatedImage];

    NSParameterAssert(self.screenshotContext);
    LIFEReportTableViewController *reportViewController = [[LIFEReportTableViewController alloc] initWithReportBuilder:self.reportBuilder context:self.screenshotContext];
    reportViewController.delegate = self;
    
    //    LIFENavigationController *nav = [[LIFENavigationController alloc] initWithRootViewController:reportViewController];
    //    [self.presentedViewController presentViewController:nav animated:YES completion:NULL];
    
    UINavigationController *nav = (UINavigationController *)self.presentedViewController;
    [nav setViewControllers:@[reportViewController] animated:YES];
}

- (void)screenshotAnnotatorViewControllerDidCancel:(nonnull LIFEScreenshotAnnotatorViewController *)screenshotAnnotatorViewController
{
    [self.reporterDelegate reporterDidCancel:self];
}

@end






@implementation LIFEEmtpyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

// This is the status bar style that shows for a very brief moment while the screenshot animation
// is being simulated, but before LIFENavigationController / the screenshot annotator has been presented
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.screenshotContext.statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.screenshotContext.statusBarHidden;
}

@end
