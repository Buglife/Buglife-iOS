//
//  LIFENavigationController.m
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

#import "LIFENavigationController.h"
#import "LIFEAppearanceImpl.h"
#import "Buglife+Protected.h"

@interface LIFENavigationController ()

// These should only be used for temporarily hiding the status bar;
// i.e. when you need to coordinate a transition.
// Otherwise, this should be NO by default.
@property (nonatomic) BOOL statusBarOverridesEnabled;
@property (nonatomic) BOOL statusBarHiddenOverride;
@property (nonatomic) UIStatusBarStyle statusBarStyleOverride;

@end

@implementation LIFENavigationController

#pragma mark - UINavigationController

- (instancetype)initWithRootViewController:(UIViewController *)viewController
{
    self = [super initWithNavigationBarClass:[LIFENavigationBar class] toolbarClass:nil];
    if (self) {
        _statusBarOverridesEnabled = NO;
        self.viewControllers = @[viewController];
        self.navigationBarStyleClear = YES;
        
        if ([Buglife sharedBuglife].useLegacyReporterUI) {
            self.navigationBar.translucent = YES;
        }
    }
    return self;
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.statusBarOverridesEnabled) {
        return self.statusBarStyleOverride;
    } else {
        return [LIFEAppearanceImpl sharedAppearance].statusBarStyle;
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (self.statusBarOverridesEnabled) {
        return self.statusBarHiddenOverride;
    } else {
        return NO;
    }
}

- (void)enableStatusBarOverrideHidden:(BOOL)hidden style:(UIStatusBarStyle)style
{
    _statusBarOverridesEnabled = YES;
    _statusBarHiddenOverride = hidden;
    _statusBarStyleOverride = style;
}

- (void)disableStatusBarOverride
{
    _statusBarOverridesEnabled = NO;
}

// LIFENavigationController is presumably always shown full screen.
// LIFEContainerViewController uses this method to determine
// whether its child should capture status bar appearance
- (BOOL)modalPresentationCapturesStatusBarAppearance
{
    return YES;
}

#pragma mark - Public

- (void)setNavigationBarStyleClear:(BOOL)navigationBarStyleClear
{
    _navigationBarStyleClear = navigationBarStyleClear;
    
    if (_navigationBarStyleClear) {
        self.navigationBar.shadowImage = [[UIImage alloc] init];
    } else {
        self.navigationBar.shadowImage = nil;
    }

    [self _configureNavigationBarAppearance];
}

- (void)_configureNavigationBarAppearance
{
    id<LIFEAppearance> appearance = [LIFEAppearanceImpl sharedAppearance];
    self.navigationBar.tintColor = appearance.tintColor;
    self.navigationBar.barTintColor = appearance.barTintColor;
    self.navigationBar.titleTextAttributes = appearance.titleTextAttributes;
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[LIFENavigationBar class]]];
    barButtonItemAppearance.tintColor = appearance.tintColor;
    [barButtonItemAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName : appearance.tintColor} forState:UIControlStateNormal];
    
    UIColor *disabledTintColor = [appearance.tintColor colorWithAlphaComponent:0.35];
    [barButtonItemAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName : disabledTintColor} forState:UIControlStateDisabled];
}

@end

@implementation LIFENavigationBar
@end
