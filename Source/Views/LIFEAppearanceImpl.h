//
//  LIFEAppearanceImpl.h
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

#import <Foundation/Foundation.h>
#import "Buglife.h" // Import Buglife.h instead of LIFEAppearance.h so we don't get a "duplicate protocol definition" warning

@interface LIFEAppearanceImpl : NSObject <LIFEAppearance>

@property (class, nonatomic, nonnull, readonly) LIFEAppearanceImpl *sharedAppearance;

@property (nonatomic, null_resettable) UIColor *tintColor;
@property (nonatomic, null_resettable) UIColor *barTintColor;
@property (nonatomic, null_resettable, copy) NSDictionary<NSString *,id> *titleTextAttributes;
@property (nonatomic) UIStatusBarStyle statusBarStyle;

@end
