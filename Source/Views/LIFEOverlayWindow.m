//
//  LIFEOverlayWindow.m
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

#import "LIFEOverlayWindow.h"

@interface LIFEOverlayWindowViewController : UIViewController

@property (nonatomic) UIStatusBarStyle statusBarStyle;
@property (nonatomic) BOOL statusBarHidden;

@end

@implementation LIFEOverlayWindow

+ (instancetype)overlayWindow
{
    LIFEOverlayWindowViewController *viewController = [[LIFEOverlayWindowViewController alloc] init];
    viewController.statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    viewController.statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    
    LIFEOverlayWindow *window = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = viewController;
    window.windowLevel = LIFEOverlayWindowLevel();
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

static UIWindowLevel LIFEOverlayWindowLevel() {
    return (UIWindowLevelAlert + 1);
}

@end

@implementation LIFEOverlayWindowViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return _statusBarHidden;
}

@end
