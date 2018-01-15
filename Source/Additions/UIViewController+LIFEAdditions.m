//
//  UIViewController+LIFEAdditions.m
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

#import "UIViewController+LIFEAdditions.h"
#import "LIFEContainerViewController.h"

@implementation UIViewController (LIFEAdditions)

LIFE_CATEGORY_METHOD_IMPL(UIViewController)

- (nullable LIFEContainerViewController *)life_containerViewController
{
    if ([self.parentViewController isKindOfClass:[LIFEContainerViewController class]]) {
        return (LIFEContainerViewController *)self.parentViewController;
    } else {
        return [self.parentViewController life_containerViewController];
    }
}

@end

LIFE_CATEGORY_FUNCTION_IMPL(UIViewController);
