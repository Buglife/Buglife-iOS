//
//  LIFEScreenshotContext.m
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

#import "LIFEScreenshotContext.h"

@interface LIFEScreenshotContext ()

@property (nonatomic) UIStatusBarStyle statusBarStyle;
@property (nonatomic) BOOL statusBarHidden;

@end

@implementation LIFEScreenshotContext

+ (instancetype)currentContext
{
    LIFEScreenshotContext *context = [[LIFEScreenshotContext alloc] init];
    context.statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    context.statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    return context;
}

@end
