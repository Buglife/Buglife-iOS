//
//  Buglife+UIStuff.m
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

#import "Buglife+UIStuff.h"
#import "LIFEBugButtonWindow.h"
#import "UIView+LIFEAdditions.h"
#import "LIFEMacros.h"
#import "LIFEOverlayWindow.h"
#import "LIFENotificationLogger.h"
#import "LIFECompatibilityUtils.h"
#import "LIFEAlertController.h"
#import "LIFEAlertAction.h"
#import "LIFEContainerWindow.h"
#import "LIFEContainerViewController.h"
#import "UIApplication+LIFEAdditions.h"
#import "LIFEDataProvider.h"

// Block type that can be used as a handler for both LIFEAlertAction and UIAlertAction
typedef void (^LIFEAlertOrUIAlertActionHandler)(NSObject *action);

@implementation Buglife (UIStuff)

+ (void)life_loadCategory_BuglifeUIStuff { }

#pragma mark - Bug Button

- (BOOL)isBugButtonWindowEnabled
{
    return self.bugButtonWindow != nil;
}

#pragma mark - UIAlert stuff

- (void)_presentAlertControllerForInvocation:(LIFEInvocationOptions)invocation withScreenshot:(UIImage *)screenshot
{
    [self _notifyBuglifeInvoked];
    [self.dataProvider logClientEventWithName:@"reporter_invoked"];
    
    // Hide the keyboard before showing the alert
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponder = [keyWindow life_firstResponder];
    
    if (firstResponder) {
        if ([firstResponder canResignFirstResponder]) {
            BOOL resigned = [firstResponder resignFirstResponder];
            
            if (resigned == NO) {
                LIFELogExtError(@"Buglife error: %@ returned YES from -canResignFirstResponder, but returned NO from -resignFirstResponder.", LIFEDebugDescription(firstResponder));
            }
        } else {
            LIFELogExtWarn(@"Buglife warning: Found first responder %@, but -canResignFirstResponder returned NO.", LIFEDebugDescription(firstResponder));
        }
    } else {
        LIFELogIntDebug(@"Buglife didn't find a first responder for window %@", LIFEDebugDescription(keyWindow));
    }

    BOOL bugButtonIsEnabled = self.isBugButtonWindowEnabled;

    if (bugButtonIsEnabled) {
        [self.bugButtonWindow setBugButtonHidden:YES animated:YES];
    }

    NSString *message = [self _alertMessageForInvocation:invocation];
    
    UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
    
    BOOL isIpad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    BOOL systemScreenshotThumbnailVisible = (invocation == LIFEInvocationOptionsScreenshot) && ([LIFECompatibilityUtils isiOS11OrHigher]);
    BOOL isScreenRecordingInvocation = (invocation == LIFEInvocationOptionsScreenRecordingFinished);
    
    if (isIpad || systemScreenshotThumbnailVisible || isScreenRecordingInvocation) {
        // On iPad, UIAlertControllerStyleActionSheet must be presented as a popover, so we just use an alert.
        // In iOS 11, if the user took a screenshot then we don't want to overlap the system screenshot thumbnail in the bottom left corner,
        // so we use an alert instead of an action sheet.
        // If it's a screen recording invocation, then we should match
        // the "alert" style of the "stop screen recording" alert.
        style = UIAlertControllerStyleAlert;
    }
    
    LIFEAlertOrUIAlertActionHandler reportHandler = ^void(NSObject *action) {
        [self _presentReporterFromInvocation:invocation withScreenshot:screenshot animated:YES];
    };
    
    LIFEAlertOrUIAlertActionHandler disableHandler;
    NSString *disableTitle;
    
    if (self.hideUntilNextLaunchButtonEnabled) {
        if (invocation == LIFEInvocationOptionsScreenRecordingFinished) {
            disableTitle = LIFELocalizedString(LIFEStringKey_DontAskUntilNextLaunch);
        } else if (invocation == LIFEInvocationOptionsFloatingButton) {
            disableTitle = LIFELocalizedString(LIFEStringKey_HideUntilNextLaunch);
        } else if (invocation == LIFEInvocationOptionsScreenshot) {
            disableTitle = LIFELocalizedString(LIFEStringKey_DontAskUntilNextLaunch);
        } else if (invocation == LIFEInvocationOptionsShake) {
            disableTitle = LIFELocalizedString(LIFEStringKey_DontAskUntilNextLaunch);
        } else if (invocation == LIFEInvocationOptionsNone) {
            // Do nothing
        }
        
        if (disableTitle) {
            disableHandler = ^void(NSObject *action) {
                if (bugButtonIsEnabled) {
                    [self.bugButtonWindow setBugButtonHidden:NO animated:YES];
                }
                
                [self _temporarilyDisableInvocation:invocation];
            };
        }
    }
    
    LIFEAlertOrUIAlertActionHandler cancelHandler = ^void(NSObject *action) {
        if (bugButtonIsEnabled) {
            [self.bugButtonWindow setBugButtonHidden:NO animated:YES];
        }
        
        [firstResponder becomeFirstResponder];
        self.reportAlertOrWindowVisible = NO;
    };
    
    UIViewController *alert = [self alertControllerWithTitle:message image:screenshot preferredStyle:style reportHandler:reportHandler disableActionTitle:disableTitle disableHandler:disableHandler cancelHandler:cancelHandler];;
    
    if (!self.useLegacyReporterUI) {
        [self _showContainerWindowWithViewController:alert animated:YES completion:nil];
    } else {
        LIFEOverlayWindow *alertWindow = [LIFEOverlayWindow overlayWindow];
        alertWindow.hidden = NO;
        [alertWindow.rootViewController presentViewController:alert animated:YES completion:NULL];
        self.overlayWindow = alertWindow;
        self.reportAlertOrWindowVisible = YES;
    }
}

- (nonnull UIViewController *)alertControllerWithTitle:(nonnull NSString *)title image:(nullable UIImage *)image preferredStyle:(UIAlertControllerStyle)style reportHandler:(LIFEAlertOrUIAlertActionHandler)reportHandler disableActionTitle:(nullable NSString *)disableActionTitle disableHandler:(LIFEAlertOrUIAlertActionHandler)disableHandler cancelHandler:(LIFEAlertOrUIAlertActionHandler)cancelHandler
{
    BOOL showDisableButton = (disableActionTitle != nil && disableHandler != nil);
    
    if (!self.useLegacyReporterUI) {
        let alert = [LIFEAlertController alertControllerWithTitle:title message:nil preferredStyle:style];
        
        if (image) {
            [alert setImage:image];
        }
        
        let reportAction = [LIFEAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_ReportABug) style:UIAlertActionStyleDefault handler:reportHandler];
        [alert addAction:reportAction];
        
        if (showDisableButton) {
            let disableAction = [LIFEAlertAction actionWithTitle:disableActionTitle style:UIAlertActionStyleDestructive handler:disableHandler];
            [alert addAction:disableAction];
        }
        
        let cancelAction = [LIFEAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_Cancel) style:UIAlertActionStyleCancel handler:cancelHandler];
        [alert addAction:cancelAction];
        
        return alert;
    } else {
        let alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:style];
        let reportAction = [UIAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_ReportABug) style:UIAlertActionStyleDefault handler:reportHandler];
        [alert addAction:reportAction];
        
        if (showDisableButton) {
            let disableAction = [UIAlertAction actionWithTitle:disableActionTitle style:UIAlertActionStyleDestructive handler:disableHandler];
            [alert addAction:disableAction];
        }
        
        let cancelAction = [UIAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_Cancel) style:UIAlertActionStyleCancel handler:cancelHandler];
        [alert addAction:cancelAction];
        
        return alert;
    }
}

- (void)_notifyBuglifeInvoked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LIFENotificationLoggerBuglifeInvoked object:nil];
}

- (NSString *)_alertMessageForInvocation:(LIFEInvocationOptions)invocation
{
    NSString *message;

    if (invocation == LIFEInvocationOptionsScreenRecordingFinished) {
        return LIFELocalizedString(LIFEStringKey_ReportABugWithScreenRecording);
    } else if ([self.delegate respondsToSelector:@selector(buglife:titleForPromptWithInvocation:)]) {
        message = [self.delegate buglife:self titleForPromptWithInvocation:invocation];
    } else {
        message = [[self class] _alertMessageForInvocation:invocation];
    }
    
    return message;
}

+ (NSString *)_alertMessageForInvocation:(LIFEInvocationOptions)invocation
{
    let appName = [[UIApplication sharedApplication] life_hostApplicationName];
    
    if (appName) {
        return [NSString stringWithFormat:LIFELocalizedString(LIFEStringKey_HelpUsMakeXYZBetter), appName];
    } else {
        return LIFELocalizedString(LIFEStringKey_HelpUsMakeThisAppBetter);
    }
}

- (void)_temporarilyDisableInvocation:(LIFEInvocationOptions)invocation
{
    if (invocation == LIFEInvocationOptionsScreenRecordingFinished) {
        self.screenRecordingInvocationEnabled = NO;
    } else {
        self.invocationOptions = (self.invocationOptions & ~invocation);
    }
}

@end

void LIFELoadCategoryFor_BuglifeUIStuff() {
    [Buglife life_loadCategory_BuglifeUIStuff];
}
