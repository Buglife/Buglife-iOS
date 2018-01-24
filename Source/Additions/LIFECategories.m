//
//  LIFECategories.m
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


#import "LIFECategories.h"
#import "Buglife+UIStuff.h"
#import "UIBezierPath+LIFEAdditions.h"
#import "UIView+LIFEAdditions.h"
#import "NSArray+LIFEAdditions.h"
#import "UIImage+LIFEAdditions.h"
#import "NSMutableDictionary+LIFEAdditions.h"
#import "NSString+LIFEAdditions.h"
#import "UIDevice+LIFEAdditions.h"
#import "UIColor+LIFEAdditions.h"
#import "UIViewController+LIFEAdditions.h"
#import "UIApplication+LIFEAdditions.h"
#import "UIControl+LIFEAdditions.h"

@implementation LIFECategories

+ (void)loadCategories
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LIFELoadCategoryFor_BuglifeUIStuff();
        LIFELoadCategoryFor_UIBezierPathLIFEAdditions();
        LIFELoadCategoryFor_UIViewLIFEAdditions();
        LIFELoadCategoryFor_NSArrayLIFEAdditions();
        LIFELoadCategoryFor_UIImageLIFEAdditions();
        LIFELoadCategoryFor_NSStringLIFEAdditions();
        LIFELoadCategoryFor_NSMutableDictionaryLIFEAdditions();
        LIFELoadCategoryFor_UIDeviceLIFEAdditions();
        LIFELoadCategoryFor_UIColorLIFEAdditions();
        LIFELoadCategoryFor_UIViewControllerLIFEAdditions();
        LIFELoadCategoryFor_UIApplicationLIFEAdditions();
        LIFELoadCategoryFor_UIControlLIFEAdditions();
    });
}

@end
