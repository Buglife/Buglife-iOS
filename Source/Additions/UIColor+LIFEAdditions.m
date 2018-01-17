//
//  UIColor+LIFEAdditions.m
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

#import "UIColor+LIFEAdditions.h"

@implementation UIColor (LIFEAdditions)

LIFE_CATEGORY_METHOD_IMPL(UIColor)

+ (instancetype)life_annotationStrokeColor
{
    return [self whiteColor];
}

+ (instancetype)life_annotationFillColor
{
    return [self colorWithRed:0.94 green:0 blue:0.38 alpha:1];
}

#pragma mark - Brand colors

+ (instancetype)life_buglifeTurqoise
{
    return [self life_colorWithHexValue:0x00d9c7];
}

+ (instancetype)life_buglifeNavy
{
    return [self life_colorWithHexValue:0x242a33];
}

+ (instancetype)life_buglifeBlue
{
    return [self life_colorWithHexValue:0x007cdc];
}

+ (instancetype)life_buglifePurple
{
    return [self life_colorWithHexValue:0x5e07dd];
}

#pragma mark - Helper factory methods

- (instancetype)life_grayscale
{
    CGFloat red = 0;
    CGFloat blue = 0;
    CGFloat green = 0;
    CGFloat alpha = 0;
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        return [UIColor colorWithWhite:(0.299*red + 0.587*green + 0.114*blue) alpha:alpha];
    } else {
        return self;
    }
}

+ (instancetype)life_color255WithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [self colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:alpha];
}

+ (instancetype)life_colorWithHexValue:(NSUInteger)hexValue
{
    return [self colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0x00FF00) >>  8))/255.0
                            blue:((float)((hexValue & 0x0000FF) >>  0))/255.0
                           alpha:1.0];
}

+ (nullable instancetype)life_debugColorWithAlpha:(CGFloat)alpha
{
#if DEBUG
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [self colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    return color;
#else
    return nil;
#endif
}

@end

LIFE_CATEGORY_FUNCTION_IMPL(UIColor);
