//
//  LIFEAppearanceImpl.m
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

#import "LIFEAppearanceImpl.h"
#import "UIColor+LIFEAdditions.h"

@implementation LIFEAppearanceImpl

+ (instancetype)sharedAppearance
{
    static LIFEAppearanceImpl *sSharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[self alloc] init];
        
        // Reset all properties
        sSharedInstance.tintColor = nil;
        sSharedInstance.barTintColor = nil;
        sSharedInstance.titleTextAttributes = nil;
        sSharedInstance.statusBarStyle = UIStatusBarStyleLightContent;
    });
    return sSharedInstance;
}

#pragma mark - LIFEAppearance

- (void)setTintColor:(UIColor *)tintColor
{
    if (tintColor == nil) {
        tintColor = [UIColor life_buglifeTurqoise];
    }
    
    _tintColor = tintColor;
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
    if (barTintColor == nil) {
        barTintColor = [UIColor life_buglifeNavy];
    }
    
    _barTintColor = barTintColor;
}

- (void)setTitleTextAttributes:(NSDictionary<NSString *,id> *)titleTextAttributes
{
    if (titleTextAttributes == nil) {
        titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    }
    
    _titleTextAttributes = titleTextAttributes;
}

@end
