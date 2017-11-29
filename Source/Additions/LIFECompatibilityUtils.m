//
//  LIFECompatibilityUtils.m
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

#import "LIFECompatibilityUtils.h"
#import <UIKit/UIKit.h>

@implementation LIFECompatibilityUtils

#pragma mark - Public methods

+ (BOOL)isForceTouchAvailableForViewController:(UIViewController *)viewController
{
    if ([self _isForceTouchAPIAvailable]) {
        return viewController.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    
    return NO;
}

+ (BOOL)isForceTouchAvailableForView:(UIView *)view
{
    if ([self _isForceTouchAPIAvailable]) {
        return view.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    
    return NO;
}

+ (BOOL)isiOS9OrHigher
{
    return [self _isiOSVersionMajorOrHigher:9];
}

+ (BOOL)isiOS10OrHigher
{
    return [self _isiOSVersionMajorOrHigher:10];
}

+ (BOOL)isiOS11OrHigher
{
    return [self _isiOSVersionMajorOrHigher:11];
}

#pragma mark - Private methods

+ (BOOL)_isForceTouchAPIAvailable
{
    return [UIViewController instancesRespondToSelector:@selector(traitCollection)] && [UITraitCollection instancesRespondToSelector:@selector(forceTouchCapability)] && [UITouch instancesRespondToSelector:@selector(force)];
}

+ (BOOL)_isiOSVersionMajorOrHigher:(NSInteger)major
{
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    
    if ([processInfo respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        NSOperatingSystemVersion version = (NSOperatingSystemVersion){major,0,0};
        return [processInfo isOperatingSystemAtLeastVersion:version];
    } else {
        return NO;
    }
}

@end
