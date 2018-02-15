//
//  Buglife.m
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

#import "Buglife.h"
#import "Buglife+UIStuff.h"
#import "LIFEAppearanceImpl.h"
#import "LIFEReportViewControllerDelegate.h"
#import "LIFEReport.h"
#import "LIFEReportAttachmentImpl.h"
#import "LIFEReportBuilder.h"
#import "LIFEMacros.h"
#import "LIFEDataProvider.h"
#import "LIFEReportTableViewController.h"
#import "UIApplication+LIFEAdditions.h"
#import "LIFEScreenshotAnnotatorViewController.h"
#import "LIFENavigationController.h"
#import "LIFEBugButtonWindow.h"
#import "LIFEUserDefaults.h"
#import "UIWindow+LIFEAdditions.h"
#import "NSArray+LIFEAdditions.h"
#import "LIFECategories.h"
#import "LIFEReportWindow.h"
#import "LIFEReportOwner.h"
#import "LIFESwizzler.h"
#import "LIFEOverlayWindow.h"
#import "LIFEAttachmentManager.h"
#import "LIFECompatibilityUtils.h"
#import "LIFEScreenshotContext.h"
#import "LIFEAttribute.h"
#import "LIFETextInputField.h"
#import "LIFEInputField+Protected.h"
#import "NSArray+LIFEAdditions.h"
#import "LIFEVideoAttachment.h"
#import "LIFEImagePickerController.h"
#import "LIFEContainerWindow.h"
#import "LIFEContainerViewController.h"
#import "LIFEImageEditorViewController.h"
#import "LIFEToastController.h"
#import "UIControl+LIFEAdditions.h"

static NSString * const kSDKVersion = @"2.8.0";
void life_dispatch_async_to_main_queue(dispatch_block_t block);

LIFEAttachmentType * const LIFEAttachmentTypeIdentifierText   = @"public.plain-text";
LIFEAttachmentType * const LIFEAttachmentTypeIdentifierJSON   = @"public.json";
LIFEAttachmentType * const LIFEAttachmentTypeIdentifierSqlite = @"com.buglife.buglife.sqlite";
LIFEAttachmentType * const LIFEAttachmentTypeIdentifierImage  = @"public.image";
LIFEAttachmentType * const LIFEAttachmentTypeIdentifierPNG    = @"public.png";
LIFEAttachmentType * const LIFEAttachmentTypeIdentifierJPEG   = @"public.jpeg";

NSString * const LIFENotificationWillPresentReporter    = @"LIFENotificationWillPresentReporter";
NSString * const LIFENotificationUserCanceledReport     = @"LIFENotificationUserCanceledReport";
NSString * const LIFENotificationUserSubmittedReport    = @"LIFENotificationUserSubmittedReport";

/**
 UIScreenCapturedDidChangeNotification is only available on iOS 11, but
 we can't strong-link this symbol because we still need to support Xcode 8.
 And since this notification gets used at startup, we probably shouldn't try
 to dynamically load it. So... we'll just use a copy of the string value,
 and hope the value doesn't change between OS versions (yeah, not great).
 */
static NSString * const LIFE_UIScreenCapturedDidChangeNotification = @"UIScreenCapturedDidChangeNotification";

const LIFEInvocationOptions LIFEInvocationOptionsScreenRecordingFinished = 1 << 6;

@interface Buglife () <LIFEReporterDelegate, LIFEBugButtonWindowDelegate, LIFEImageEditorViewControllerDelegate, LIFEReportViewControllerDelegate>

@property (nonatomic) LIFEReportOwner *reportOwner;
@property (nonatomic) BOOL debugMode;
@property (nonatomic) LIFEReportWindow *reportWindow;

// Used to store weak refs to windows for UIAlertControllers, so
// we can set the window to hidden after the alert is dismissed
@property (nonatomic, weak) LIFEOverlayWindow *overlayWindow;
@property (nonatomic) LIFEContainerWindow *containerWindow;
@property (nonatomic) BOOL reportAlertOrWindowVisible;
@property (nonatomic) LIFEDataProvider *dataProvider;
@property (nonatomic) LIFEBugButtonWindow *bugButtonWindow;
@property (nonatomic) UIInterfaceOrientation capturedOrientation; // the orientation of the device at time of screenshot capture
@property (nonatomic) LIFEInvocationOptions lastUsedInovcationMethod;
@property (nonatomic, getter=isScreenRecordingInvocationEnabled) BOOL screenRecordingInvocationEnabled;

@property (nonatomic) NSString *userIdentifier;
@property (nonatomic) NSString *userEmail;
@property (nonatomic) LIFEAttachmentManager *attachmentManager;

@property (nonatomic) LIFEInputField *userEmailField;
@property (nonatomic) NSMutableDictionary<NSString *, LIFEAttribute *> *attributes;
// This should only be used when presenting the initial
// image editor
@property (nonatomic, nullable) LIFEReportBuilder *reportBuilder;

/**
 These should be made public in an upcoming release.
 */
@property (nonatomic, null_resettable) NSString *thankYouMessage;
@property (nonatomic, null_resettable) NSString *titleForReportViewController;

// Legacy features, but some people might still want to use them.
// If they're dying for it, let them use it via private API.
@property (nonatomic) BOOL hideUntilNextLaunchButtonEnabled;
@property (nonatomic) BOOL useLegacyReporterUI;

@end

@implementation Buglife

#pragma mark - Public

+ (instancetype)sharedBuglife
{
    static Buglife *sSharedBuglife = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([LIFECompatibilityUtils isiOS9OrHigher]) {
            sSharedBuglife = [[self alloc] initInternal];
        } else {
            LIFELogExtWarn(@"Buglife Warning: This version of the Buglife SDK only supports iOS 9 or higher.");
        }
    });
    return sSharedBuglife;
}

- (instancetype)initInternal
{
    self = [super init];
    if (self) {
        _debugMode = NO;
        _reportAlertOrWindowVisible = NO;
        _hideUntilNextLaunchButtonEnabled = NO;
        _captureUserEventsEnabled = YES;
        _allowsAdditionalAttachments = YES;
        _attachmentManager = [[LIFEAttachmentManager alloc] init];
        _attributes = [[NSMutableDictionary alloc] init];
        self.invocationOptions = LIFEInvocationOptionsShake;
        (void)[LIFEAwesomeLogger sharedLogger];
    }
    return self;
}

- (instancetype)init
{
    LIFELogExtError(@"Buglife Error: Sorry, Buglife is a singleton! 😁 Please initialize using +[Buglife sharedBuglife].");
    return nil;
}

#define LIFELogErrorMultipleStartAttempts LIFELogExtDebug(@"Buglife Error: Attempted to call %@ or %@ more than once! Subsequent calls will be ignored.", NSStringFromSelector(@selector(startWithAPIKey:)), NSStringFromSelector(@selector(startWithEmail:)))

- (void)startWithAPIKey:(NSString *)apiKey
{
    if ([self _isStarted]) {
        LIFELogErrorMultipleStartAttempts;
        return;
    }

    if (apiKey == nil) {
        LIFELogExtDebug(@"Buglife Error: Attempted to call [%@ %@] with a nil API Key!", NSStringFromClass([self class]), NSStringFromSelector(@selector(startWithAPIKey:)));
        return;
    }

    self.reportOwner = [LIFEReportOwner reportOwnerWithAPIKey:apiKey];
    [self _startBuglife];
}

- (void)startWithEmail:(NSString *)email
{
    if ([self _isStarted]) {
        LIFELogErrorMultipleStartAttempts;
        return;
    }
    
    if (email == nil) {
        LIFELogExtDebug(@"Buglife Error: Attempted to call [%@ %@] with a nil email!", NSStringFromClass([self class]), NSStringFromSelector(@selector(startWithEmail:)));
        return;
    }
    
    self.reportOwner = [LIFEReportOwner reportOwnerWithEmail:email];
    [self _startBuglife];
}

- (void)_startBuglife
{
    NSParameterAssert([self _isStarted]);

    // Load categories before doing anything else
    [LIFECategories loadCategories];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userDidTakeScreenshotNotification:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    self.screenRecordingInvocationEnabled = YES; // Start the screen recording observer
    
    [self _enableOrDisableBugButton];
    [self.dataProvider flushPendingReportsAfterDelay:2.0];
    [self.dataProvider logClientEventWithName:@"app_launch" afterDelay:10.0];
}

- (BOOL)_isStarted
{
    return self.reportOwner != nil;
}

- (void)presentReporter
{
    // dispatch_async to main queue in case this is called off the main thread.
    // This is also an attempt at a bug fix for @sjoerdjanssenen, who reported via DM
    // that -presentReporter was taking ~15 sec to actually show the bug reporter window.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _presentReporterFromInvocation:LIFEInvocationOptionsNone withScreenshot:nil animated:YES];
    });
}

- (NSString *)version
{
    return kSDKVersion.copy;
}

- (void)setDebugMode:(BOOL)debugMode
{
    if (debugMode != _debugMode) {
        _debugMode = debugMode;
        
        if (_debugMode) {
            [[LIFELogger sharedLogger] addToWhitelist:LIFELoggerContextInternalDebugMode];
        } else {
            [[LIFELogger sharedLogger] removeFromWhitelist:LIFELoggerContextInternalDebugMode];
        }
    }
}

- (void)setInvocationOptions:(LIFEInvocationOptions)invocationOptions
{
    if (_invocationOptions != invocationOptions) {
        _invocationOptions = invocationOptions;
        
        if ([self _isStarted]) {
            [self _enableOrDisableBugButton];
        }
    }
}
- (void)setCaptureUserEventsEnabled:(BOOL)captureUserEventsEnabled
{
    BOOL old = _captureUserEventsEnabled;
    if (old != captureUserEventsEnabled)
    {
        _captureUserEventsEnabled = captureUserEventsEnabled;
    }
    if ([self _isStarted] && captureUserEventsEnabled && !old){
        [UIControl life_swizzleSendAction];
    }
}



- (void)_enableOrDisableBugButton
{
    // Since the application's keyWindow might still be nil in -application:didFinishLaunching,
    // wait until the next run loop cycle to add the floating button to the view hierarchy
    life_dispatch_async_to_main_queue(^{
        BOOL bugButtonEnabled = (self.invocationOptions & LIFEInvocationOptionsFloatingButton) == LIFEInvocationOptionsFloatingButton;
        
        if (bugButtonEnabled) {
            self.bugButtonWindow = [[LIFEBugButtonWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.bugButtonWindow.lifeDelegate = self;
            self.bugButtonWindow.hidden = NO; // adds it to the window hierarchy
        } else {
            self.bugButtonWindow.hidden = YES;
            self.bugButtonWindow = nil;
        }
        
        BOOL shakeEnabled = (self.invocationOptions & LIFEInvocationOptionsShake) == LIFEInvocationOptionsShake;

        if (shakeEnabled) {
            [LIFEUIWindow monkeyPatchMotionEndedForBuglife:self];
        }
    });
}

// See https://github.com/Buglife/Buglife-iOS/issues/13
- (void)configureBugButtonWithForegroundColor:(nullable UIColor *)foregroundColor backgroundColor:(nullable UIColor *)backgroundColor
{
    life_dispatch_async_to_main_queue(^{
        if (self.bugButtonWindow == nil) {
            LIFELogExtWarn(@"Buglife warning: Bug button must be visible to configure colors");
        } else {
            [self.bugButtonWindow configureBugButtonWithForegroundColor:foregroundColor backgroundColor:backgroundColor];
        }
    });
}

- (nonnull UIImage *)screenshot
{
    if (![NSThread mainThread]) {
        LIFELogExtWarn(@"Buglife warning: Calling %@.%@ off the main thread is unsupported!", NSStringFromClass([self class]), NSStringFromSelector(@selector(screenshot)));
    }

    return [[UIApplication sharedApplication] life_screenshot];
}

- (id<LIFEAppearance>)appearance
{
    return [LIFEAppearanceImpl sharedAppearance];
}

#pragma mark - Protected

- (void)life_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self _shakeDetected];
    }
}

#pragma mark - Private

- (void)_userDidTakeScreenshotNotification:(NSNotification *)notification
{
    // These notifications tend to come in on the main thread, but that isn't documented anywhere so let's play it safe
    life_dispatch_async_to_main_queue(^{
        [self _screenshotDetected];
    });
}

- (void)_screenshotDetected
{
    if ((_invocationOptions & LIFEInvocationOptionsScreenshot) && !self.reportAlertOrWindowVisible) {
        UIImage *screenshot = [self _screenshot];
        [self _presentAlertControllerForInvocation:LIFEInvocationOptionsScreenshot withScreenshot:screenshot];
    }
}

- (void)_shakeDetected
{
    if ((_invocationOptions & LIFEInvocationOptionsShake) && !self.reportAlertOrWindowVisible) {
        UIImage *screenshot = [self _screenshot];
        [self _presentAlertControllerForInvocation:LIFEInvocationOptionsShake withScreenshot:screenshot];
    }
}

- (void)_presentReporterFromInvocation:(LIFEInvocationOptions)invocation withScreenshot:(UIImage *)screenshot animated:(BOOL)animated
{
    if (![self _isStarted]) {
        LIFELogExtDebug(@"Buglife Error: Attempted to present Buglife reporter with no API key or email. To fix this, make sure to invoke [%@ %@] with a valid API key, or [%@ %@] with your email address in your app delegate's %@ method.", NSStringFromClass([self class]), NSStringFromSelector(@selector(startWithAPIKey:)), NSStringFromSelector(@selector(application:didFinishLaunchingWithOptions:)), NSStringFromClass([self class]), NSStringFromSelector(@selector(startWithEmail:)));
        return;
    }
    
    //Notify interested parties that we've been invoked
    [[NSNotificationCenter defaultCenter] postNotificationName:LIFENotificationWillPresentReporter object:self];
    
    if (invocation == LIFEInvocationOptionsNone) {
        // If the reporter was presented manually, we should log it. Otherwise it should be logged at the actual invocation time
        [self _notifyBuglifeInvoked];
        [self.dataProvider logClientEventWithName:@"reporter_invoked_manually"];
    }
    
    self.lastUsedInovcationMethod = invocation;
    self.reportAlertOrWindowVisible = YES;
    
    [self.bugButtonWindow setBugButtonHidden:YES animated:animated];
    
    LIFEReportWindow *reportWindow;
    
    if (self.useLegacyReporterUI) {
        reportWindow = [LIFEReportWindow reportWindow];
        reportWindow.reporterDelegate = self;
    }
    
    LIFEReportBuilder *reportBuilder = [[LIFEReportBuilder alloc] init];
    reportBuilder.attributes = self.attributes;
    reportBuilder.creationDate = [NSDate date];
    LIFEScreenshotContext *context = [LIFEScreenshotContext currentContext];
    
    if (!self.useLegacyReporterUI) {
        UIViewController *vc;
        self.reportBuilder = reportBuilder;
        void (^completionBlock)(void) = nil;
        
        if (screenshot) {
            let ivc = [[LIFEImageEditorViewController alloc] initWithScreenshot:screenshot context:context];
            ivc.initialViewController = YES;
            ivc.delegate = self;
            vc = ivc;
        } else {
            let rvc = [[LIFEReportTableViewController alloc] initWithReportBuilder:self.reportBuilder];
            rvc.delegate = self;
            vc = rvc;
            
            if (invocation == LIFEInvocationOptionsScreenRecordingFinished) {
                completionBlock = ^{
                    [rvc addLastVideoAsAttachment];
                };
            }
        }
        
        let nav = [[LIFENavigationController alloc] initWithRootViewController:vc];
        [self _showContainerWindowWithViewController:nav animated:animated completion:completionBlock];
    } else {
        if (screenshot) {
            BOOL simulateScreenshotCapture = (invocation != LIFEInvocationOptionsScreenshot);
            [reportWindow presentReporterWithReportBuilder:reportBuilder screenshot:screenshot context:context simulateScreenshotCapture:simulateScreenshotCapture animated:animated];
        } else {
            [reportWindow presentReporterWithReportBuilder:reportBuilder context:context animated:animated completion:^(LIFEReportTableViewController *reportTableViewController) {
                if (invocation == LIFEInvocationOptionsScreenRecordingFinished) {
                    [reportTableViewController addLastVideoAsAttachment];
                }
            }];
        }
    }
    
    [self _requestAttachmentsForReportBuilder:reportBuilder];
    
    if (self.useLegacyReporterUI) {
        self.reportWindow = reportWindow;
    }
    
    [self.dataProvider logClientEventWithName:@"presented_reporter" afterDelay:2.0];
}

- (void)_showContainerWindowWithViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    if (self.containerWindow == nil) {
        self.containerWindow = [LIFEContainerWindow window];
        self.containerWindow.hidden = NO;
    }
    
    [self.containerWindow.containerViewController life_presentViewController:viewController animated:animated completion:completion];
    self.reportAlertOrWindowVisible = YES;
}

- (void)_dismissReporterAnimated:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    
    [self.containerWindow.containerViewController life_dismissEverythingAnimated:animated completion:^{
        __strong Buglife *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf _reporterAndThankYouDialogDidDismissAnimated:animated];
        }
    }];
    
    [self.reportWindow dismissAnimated:animated completion:^{
        __strong Buglife *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf _reporterAndThankYouDialogDidDismissAnimated:animated];
        }
    }];
}

- (void)_dismissReporterWithWindowBlindsAnimation:(BOOL)animated andShowThankYouDialog:(BOOL)shouldShowThankYouDialog
{
    if (shouldShowThankYouDialog && [self.delegate respondsToSelector:@selector(buglifeWillPresentReportCompletedDialog:)]) {
        shouldShowThankYouDialog = [self.delegate buglifeWillPresentReportCompletedDialog:self];
    }
    
    __weak typeof(self) weakSelf = self;
    
    LIFEToastController *toast = shouldShowThankYouDialog ? [[LIFEToastController alloc] init] : nil;
    [self.containerWindow.containerViewController dismissWithWindowBlindsAnimation:animated showToast:toast completion:^{
        __strong Buglife *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf _reporterAndThankYouDialogDidDismissAnimated:animated];
        }
    }];

    [self.reportWindow dismissAnimated:animated completion:^{
        __strong Buglife *strongSelf = weakSelf;
        if (strongSelf) {
            if (shouldShowThankYouDialog) {
                [strongSelf _showThankYouDialogWithCancelActionHandler:^{
                    __strong Buglife *strongSelf2 = weakSelf;
                    if (strongSelf2) {
                        [strongSelf2 _reporterAndThankYouDialogDidDismissAnimated:animated];
                    }
                }];
            } else {
                [strongSelf _reporterAndThankYouDialogDidDismissAnimated:animated];
            }
        }
    }];
}

- (void)_reporterAndThankYouDialogDidDismissAnimated:(BOOL)animated
{
    // We need to set the rootViewController of the window to nil when we hide the window;
    // This fixes an issue where hiding the window, then subsequently rotating the device
    // will rotate the status bar even when the host app's key window's view controller
    // has rotation disabled.
    self.reportWindow.rootViewController = nil;
    self.reportWindow.hidden = YES;
    self.reportWindow = nil;
    self.containerWindow.rootViewController = nil;
    self.containerWindow.hidden = YES;
    self.containerWindow = nil;
    self.reportAlertOrWindowVisible = NO;
    [self.bugButtonWindow setBugButtonHidden:NO animated:animated];
}

// This obviously won't work for long
- (UIViewController *)_applicationRootViewController
{
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *windows = application.windows;
    UIWindow *window = windows.firstObject;
    return window.rootViewController;
}

#pragma mark - Screen recording

- (void)setScreenRecordingInvocationEnabled:(BOOL)screenRecordingInvocationEnabled
{
    if (_screenRecordingInvocationEnabled != screenRecordingInvocationEnabled) {
        _screenRecordingInvocationEnabled = screenRecordingInvocationEnabled;
        
        if ([LIFECompatibilityUtils isiOS11OrHigher]) {
            if (_screenRecordingInvocationEnabled) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_screenCapturedDidChangeNotification:) name:LIFE_UIScreenCapturedDidChangeNotification object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:LIFE_UIScreenCapturedDidChangeNotification object:nil];
            }
        }
    }
}

- (void)_screenCapturedDidChangeNotification:(NSNotification *)notification NS_AVAILABLE_IOS(11_0)
{
    UIScreen *screen = notification.object;
    LIFELogIntDebug(@"\n\nScreen capture did change notification:\nNotification: %@\nUserinfo: %@\nCaptured:%d\n\n", notification, notification.userInfo, screen.isCaptured);
    
    if (screen) {
        BOOL screenRecordingFinished = !screen.isCaptured;
        
        if (screenRecordingFinished) {
            [self _screenRecordingFinished];
        }
    } else {
        LIFELogExtError(@"Received screen capture did change notification, but notification object is nil");
    }
}

- (void)_screenRecordingFinished
{
    if (!self.reportAlertOrWindowVisible) {
        [self _presentAlertControllerForInvocation:LIFEInvocationOptionsScreenRecordingFinished withScreenshot:nil];
    }
}

#pragma mark - Accessors

- (LIFEDataProvider *)dataProvider
{
    if (_dataProvider == nil) {
        _dataProvider = [[LIFEDataProvider alloc] initWithReportOwner:self.reportOwner SDKVersion:self.version];
    }
    
    return _dataProvider;
}

- (void)setReportAlertOrWindowVisible:(BOOL)reportAlertOrWindowVisible
{
    if (_reportAlertOrWindowVisible != reportAlertOrWindowVisible) {
        _reportAlertOrWindowVisible = reportAlertOrWindowVisible;
        
        if (_reportAlertOrWindowVisible == NO) {
            __strong LIFEOverlayWindow *strongOverlayWindow = self.overlayWindow;
            
            if (strongOverlayWindow) {
                strongOverlayWindow.hidden = YES;
            }

            self.overlayWindow = nil;
            
            __strong LIFEContainerWindow *strongContainerWindow = self.containerWindow;
            
            if (strongContainerWindow) {
                strongContainerWindow.hidden = YES;
            }
            
            self.containerWindow = nil;
        }
        
        self.capturedOrientation = [UIApplication sharedApplication].statusBarOrientation;
        [LIFESwizzler instanceSwizzleFromClass:[UIApplication class] andMethod:@selector(supportedInterfaceOrientationsForWindow:) toClass:[self class] andMethod:@selector(supportedInterfaceOrientationsForWindow:)];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIInterfaceOrientation orientation = [Buglife sharedBuglife].capturedOrientation;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIInterfaceOrientationMaskPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return UIInterfaceOrientationMaskLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscapeRight;
        default:
            return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - Screenshots

- (UIImage *)_screenshot
{
    return [[UIApplication sharedApplication] life_screenshot];
}

#pragma mark - Test helpers

void life_dispatch_async_to_main_queue(dispatch_block_t block) {
    [Buglife dispatchToMainQueue:block];
}

+ (void)dispatchToMainQueue:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

- (UIWindow *)_applicationKeyWindow
{
    return [[UIApplication sharedApplication] keyWindow];
}

#pragma mark - LIFEImageEditorViewControllerDelegate

- (void)imageEditorViewController:(LIFEImageEditorViewController *)controller willCompleteWithAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    [self.reportBuilder addAnnotatedImage:annotatedImage];
    let vc = [[LIFEReportTableViewController alloc] initWithReportBuilder:self.reportBuilder];
    vc.delegate = self;
    [self.containerWindow.containerViewController life_setChildViewController:vc animated:YES completion:nil];
}

- (void)imageEditorViewControllerDidCancel:(nonnull LIFEImageEditorViewController *)controller
{
    [self _dismissReporterAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:LIFENotificationUserCanceledReport object:self];
    if ([self.delegate respondsToSelector:@selector(buglife:userCanceledReportWithAttributes:)])
    {
        [self.delegate buglife:self userCanceledReportWithAttributes:[NSDictionary dictionaryWithDictionary:self.attributes]];
    }
}

#pragma mark - LIFEReportViewControllerDelegate

- (BOOL)reportViewControllerShouldSubmitSynchronously:(nonnull LIFEReportTableViewController *)reportViewController
{
    return [self reporterShouldSubmitSynchronously:nil];
}

- (void)reportViewControllerDidCancel:(nonnull LIFEReportTableViewController *)reportViewController
{
    [self reporterDidCancel:nil];
}

- (void)reportViewController:(nonnull LIFEReportTableViewController *)reportViewController shouldCompleteReportBuilder:(nonnull LIFEReportBuilder *)reportBuilder completion:(void (^_Nullable)(BOOL finished))completion
{
    [self reporter:nil shouldCompleteReportBuilder:reportBuilder completion:completion];
}

#pragma mark - LIFEReporterDelegate

- (BOOL)reporterShouldSubmitSynchronously:(nullable LIFEReportWindow *)reporter
{
    return self.retryPolicy == LIFERetryPolicyManualRetry;
}

- (void)reporterDidCancel:(nullable LIFEReportWindow *)reporter
{
    [self _dismissReporterAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:LIFENotificationUserCanceledReport object:self];
    if ([self.delegate respondsToSelector:@selector(buglife:userCanceledReportWithAttributes:)])
    {
        [self.delegate buglife:self userCanceledReportWithAttributes:[NSDictionary dictionaryWithDictionary:self.attributes]];
    }
}

- (void)reporter:(LIFEReportWindow *)reporter shouldCompleteReportBuilder:(LIFEReportBuilder *)reportBuilder completion:(void (^)(BOOL))completion
{
    NSParameterAssert([NSThread isMainThread]);
    
    reportBuilder.userIdentifier = self.userIdentifier;
    reportBuilder.invocationMethod = self.lastUsedInovcationMethod;
    LIFERetryPolicy retryPolicy = self.retryPolicy;
    BOOL waitUntilSuccessfulSubmissionToDismissReporter = (retryPolicy == LIFERetryPolicyManualRetry);
    
    // TODO: build to something other than the main queue
    [reportBuilder buildReportToQueue:dispatch_get_main_queue() completion:^(LIFEReport *report) {
        [self.dataProvider submitReport:report withRetryPolicy:retryPolicy completion:^(BOOL submittedSuccessfully) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(submittedSuccessfully);
                }
                
                if (submittedSuccessfully) {
                    [self _didCompleteReport:report];
                    
                    if (waitUntilSuccessfulSubmissionToDismissReporter) {
                        [self _dismissReporterWithWindowBlindsAnimation:YES andShowThankYouDialog:YES];
                    }
                }
            });
        }];
    }];
    
    // Post this notification regardless of success of submission now; the attributes on the Buglife *now* will have been submitted eventually
    // We don't need to keep them now.
    [[NSNotificationCenter defaultCenter] postNotificationName:LIFENotificationUserSubmittedReport object:self userInfo:[NSDictionary dictionaryWithDictionary:self.attributes]];
    
    if (!waitUntilSuccessfulSubmissionToDismissReporter) {
        [self _dismissReporterWithWindowBlindsAnimation:YES andShowThankYouDialog:YES];
    }
}

- (void)_didCompleteReport:(nonnull LIFEReport *)report
{
    NSParameterAssert([NSThread isMainThread]);
    
    if ([self.delegate respondsToSelector:@selector(buglifeDidCompleteReportWithAttributes:)]) {
        NSMutableDictionary<NSString *, NSString *> *mutableAttributes = [NSMutableDictionary dictionary];
        
        for (NSString *attributeName in report.attributes.allKeys) {
            let attributeValue = report.attributes[attributeName].stringValue;
            
            if (attributeValue) {
                mutableAttributes[attributeName] = attributeValue;
            }
        }
        
        NSDictionary<NSString *, NSString *> *attributes = [NSDictionary dictionaryWithDictionary:mutableAttributes];
        [self.delegate buglifeDidCompleteReportWithAttributes:attributes];
    }
}

#pragma mark - Thanks

- (void)_showThankYouDialogWithCancelActionHandler:(void (^)(void))cancelActionHandler
{
    LIFEOverlayWindow *overlayWindow = [LIFEOverlayWindow overlayWindow];
    __weak LIFEOverlayWindow *weakOverlayWindow = overlayWindow;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.thankYouMessage message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_OK) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelActionHandler) {
            cancelActionHandler();
        }

        __strong LIFEOverlayWindow *strongOverlayWindow = weakOverlayWindow;
        
        if (strongOverlayWindow) {
            strongOverlayWindow.hidden = YES;
        }
    }]];

    overlayWindow.hidden = NO;
    [overlayWindow.rootViewController presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - LIFEBugButtonWindowDelegate

- (void)bugButtonWasTappedInWindow:(LIFEBugButtonWindow *)bugButtonWindow
{
    UIImage *screenshot = [self _screenshot];
    [self _presentAlertControllerForInvocation:LIFEInvocationOptionsFloatingButton withScreenshot:screenshot];
}

#pragma mark - Attachments

- (BOOL)addAttachmentWithData:(NSData *)attachmentData type:(NSString *)attachmentType filename:(NSString *)filename error:(NSError * _Nullable * _Nullable)error
{
    return [_attachmentManager syncAddAttachmentWithData:attachmentData type:attachmentType filename:filename error:error requestsClosedHandler:^{
        // We used to log a warning here, but it's not necessary anymore
    }];
}

- (void)addAttachmentWithImage:(nonnull UIImage *)image filename:(nonnull NSString *)filename
{
    [_attachmentManager asyncAddAttachmentWithImage:image filename:filename requestsClosedHandler:^{
        // We used to log a warning here, but it's not necessary anymore
    }];
}

// This is the maximum amount of time that consumers have to call the completionHandler for attachments
static const NSTimeInterval kAttachmentRequestTimerDuration = 3;

- (void)_requestAttachmentsForReportBuilder:(LIFEReportBuilder *)reportBuilder
{
    NSParameterAssert([NSThread isMainThread]);

    if ([self.delegate respondsToSelector:@selector(buglife:handleAttachmentRequestWithCompletionHandler:)]) {
        // Set a timer to make sure the consumer calls the completionHandler within some duration
        [_attachmentManager asyncOpenRequestsForDuration:kAttachmentRequestTimerDuration expirationHandler:^{
            // If the timer expires before they call the completion handler, log a warning
            LIFELogExtWarn(@"Buglife warning: The completionHandler for %@ was not called within the required timeframe; subsequent attachments will be ignored.", NSStringFromSelector(@selector(buglife:handleAttachmentRequestWithCompletionHandler:)));
        }];

        [self.delegate buglife:self handleAttachmentRequestWithCompletionHandler:^{
            // Consumers might call this completion handler on any thread
            // but self.attachmentManager should only be accessed on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.attachmentManager asyncCloseRequestsAndSettleAttachments];
                [self _flushSettledAttacmentsAndAddToReportBuilder:reportBuilder];
            });
        }];
    } else {
        // If the consumer hasn't implemented this protocol method, then they still might have
        // been adding attachments :-/
        // Therefore we need to "settle" attachments so they still get flushed later
        [_attachmentManager asyncCloseRequestsAndSettleAttachments];
        [self _flushSettledAttacmentsAndAddToReportBuilder:reportBuilder];
    }
}

- (void)_flushSettledAttacmentsAndAddToReportBuilder:(LIFEReportBuilder *)reportBuilder
{
    __weak typeof(self) weakSelf = self;
    [_attachmentManager asyncFlushSettledAttachmentsToQueue:dispatch_get_main_queue() completion:^(NSArray<LIFEReportAttachmentImpl *> *settledAttachments) {
        __strong Buglife *strongSelf = weakSelf;
        if (strongSelf) {
            [reportBuilder addAttachments:settledAttachments];
        }
    }];
}

#pragma mark - Email field

- (LIFEInputField *)userEmailField
{
    if (_userEmailField == nil) {
        _userEmailField = [LIFETextInputField userEmailInputField];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _userEmailField.visible = NO;
#pragma clang diagnostic pop
    }
    
    return _userEmailField;
}

#pragma mark - String customization

- (NSString *)thankYouMessage
{
    if (_thankYouMessage == nil) {
        _thankYouMessage = LIFELocalizedString(LIFEStringKey_ThanksForFilingABug);
    }
    
    return _thankYouMessage;
}

- (NSString *)titleForReportViewController
{
    if (_titleForReportViewController == nil) {
        _titleForReportViewController = LIFELocalizedString(LIFEStringKey_ReportABug);
    }
    
    return _titleForReportViewController;
}

#pragma mark - Input fields

- (NSArray<LIFEInputField *> *)inputFields
{
    if (_inputFields == nil) {
        NSMutableArray *inputFields = [[NSMutableArray alloc] init];
        LIFEInputField *summaryInputField = [LIFETextInputField summaryInputField];
        [inputFields addObject:summaryInputField];
        
        // The `visible` property on LIFEInputField was the old
        // way of enabling the userEmail field. It's now deprecated, but
        // if users are still using the `visible` property AND they are not
        // using custom input fields, then show the user email field.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (_userEmailField.visible) {
#pragma clang diagnostic pop
            [inputFields addObject:_userEmailField];
        }
        
        _inputFields = [NSArray arrayWithArray:inputFields];
    }
    
    return _inputFields;
}

#pragma mark - Attributes

- (void)setObjectValue:(nullable id)object forAttribute:(nonnull NSString *)attribute
{
    NSString *value = [object description];
    [self setStringValue:value forAttribute:attribute];
}

- (void)setStringValue:(NSString *)stringValue forAttribute:(NSString *)attributeKey
{
    if (stringValue == nil) {
        [self removeAttribute:attributeKey];
    } else {
        LIFEAttribute *attribute = [[LIFEAttribute alloc] initWithValueType:LIFEAttributeValueTypeString value:stringValue flags:LIFEAttributeFlagCustom];
        [self _setAttribute:attribute forKey:attributeKey];
    }
}

- (void)removeAttribute:(NSString *)attributeKey
{
    if ([attributeKey length] > 0) {
        [_attributes removeObjectForKey:attributeKey];
    }
}

- (void)_setAttribute:(LIFEAttribute *)attribute forKey:(NSString *)attributeKey
{
    if ([attributeKey length] > 0) {
        [_attributes setObject:attribute forKey:attributeKey];
    } else {
        LIFELogError(@"Attempted to set attribute with empty attribute key: \"%@\"", attributeKey);
    }
}

@end

UIInterfaceOrientationMask interfaceOrientationMaskFromInterfaceOrientation(UIInterfaceOrientation orientation) {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIInterfaceOrientationMaskPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return UIInterfaceOrientationMaskLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscapeRight;
        default:
            return UIInterfaceOrientationMaskPortrait;
    }
}
