//
//  UIColor+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 10/27/15.
//
//

#import "UIColor+LIFEAdditions.h"

@implementation LIFEUIColor

+ (UIColor *)life_annotationStrokeColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)life_annotationFillColor
{
    return [UIColor colorWithRed:0.94 green:0 blue:0.38 alpha:1];
}

#pragma mark - Brand colors

+ (UIColor *)life_buglifeTurqoise
{
    return [LIFEUIColor life_colorWithHexValue:0x00d9c7];
}

+ (UIColor *)life_buglifeNavy
{
    return [LIFEUIColor life_colorWithHexValue:0x242a33];
}

+ (UIColor *)life_buglifeBlue
{
    return [LIFEUIColor life_colorWithHexValue:0x007cdc];
}

+ (UIColor *)life_buglifePurple
{
    return [LIFEUIColor life_colorWithHexValue:0x5e07dd];
}

#pragma mark - Helper factory methods

+ (UIColor *)life_color255WithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:alpha];
}

+ (UIColor *)life_colorWithHexValue:(NSUInteger)hexValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0x00FF00) >>  8))/255.0
                            blue:((float)((hexValue & 0x0000FF) >>  0))/255.0
                           alpha:1.0];
}

+ (nullable UIColor *)life_debugColorWithAlpha:(CGFloat)alpha
{
#if DEBUG
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    return color;
#else
    return nil;
#endif
}

@end
