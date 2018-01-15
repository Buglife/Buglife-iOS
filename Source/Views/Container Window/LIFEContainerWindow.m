//
//  LIFEContainerWindow.m
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

#import "LIFEContainerWindow.h"
#import "LIFEContainerViewController.h"
#import "LIFEMacros.h"

let kWindowLevel = 999.0f;

@implementation LIFEContainerWindow

+ (instancetype)window
{
    let viewController = [[LIFEContainerViewController alloc] init];
    viewController.statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    viewController.statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    
    LIFEContainerWindow *window = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = viewController;
    window.windowLevel = kWindowLevel;
    return window;
}

- (void)setHidden:(BOOL)hidden
{
    if (hidden) {
        // We need to set the rootViewController of the window to nil when we hide the window;
        // This fixes an issue where hiding the window, then subsequently rotating the device
        // will rotate the status bar even when the host app's key window's view controller
        // has rotation disabled.
        self.rootViewController = nil;
    }
    
    [super setHidden:hidden];
}

- (nonnull LIFEContainerViewController *)containerViewController
{
    return (LIFEContainerViewController *)self.rootViewController;
}

// Unless a touch event hits an actual subview,
// let it pass through to whatever's behind. This allows things like
// LIFEToastView to remain onscreen while allowing the host app to
// receive touches.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}


@end
