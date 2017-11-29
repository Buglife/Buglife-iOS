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

@interface LIFENavigationController ()
@end

@implementation LIFENavigationController

- (instancetype)initWithRootViewController:(UIViewController *)viewController
{
    self = [super initWithNavigationBarClass:[LIFENavigationBar class] toolbarClass:nil];
    if (self) {
        self.viewControllers = @[viewController];
        
        id<LIFEAppearance> appearance = [LIFEAppearanceImpl sharedAppearance];
        self.navigationBar.tintColor = appearance.tintColor;
        self.navigationBar.barTintColor = appearance.barTintColor;
        self.navigationBar.titleTextAttributes = appearance.titleTextAttributes;
        self.navigationBar.translucent = YES;
        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
        
        UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[LIFENavigationBar class]]];
        barButtonItemAppearance.tintColor = appearance.tintColor;
        [barButtonItemAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName : appearance.tintColor} forState:UIControlStateNormal];
        
        UIColor *disabledTintColor = [appearance.tintColor colorWithAlphaComponent:0.35];
        [barButtonItemAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName : disabledTintColor} forState:UIControlStateDisabled];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [LIFEAppearanceImpl sharedAppearance].statusBarStyle;
}

@end

@implementation LIFENavigationBar
@end
