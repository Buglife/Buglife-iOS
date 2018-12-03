//
//  UIColor+LIFEAdditions.h
//  Copyright (C) 2015-2018 Buglife, Inc.
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

#import <UIKit/UIKit.h>
#import "LIFECategories.h"

@interface UIColor (LIFEAdditions)

+ (nonnull instancetype)life_annotationStrokeColor;
+ (nonnull instancetype)life_annotationFillColor;

#pragma mark - Brand colors

+ (nonnull instancetype)life_buglifeTurqoise;
+ (nonnull instancetype)life_buglifeNavy;

#pragma mark - Helper methods

- (nonnull instancetype)life_grayscale;
+ (nonnull instancetype)life_colorWithHexValue:(NSUInteger)hexValue;
+ (nullable instancetype)life_debugColorWithAlpha:(CGFloat)alpha __deprecated_msg("This should only be used for debug builds!");;
- (BOOL)life_isLightColor;

@end

LIFE_CATEGORY_FUNCTION_DECL(UIColor);
