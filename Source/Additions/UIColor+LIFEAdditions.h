//
//  UIColor+LIFEAdditions.h
//
//  Created by David Schukin on 10/27/15.

#import <UIKit/UIKit.h>

@interface LIFEUIColor : NSObject

+ (nonnull UIColor *)life_annotationStrokeColor;
+ (nonnull UIColor *)life_annotationFillColor;

#pragma mark - Brand colors

+ (nonnull UIColor *)life_buglifeTurqoise;
+ (nonnull UIColor *)life_buglifeNavy;
//+ (nonnull UIColor *)life_buglifeBlue;
//+ (nonnull UIColor *)life_buglifePurple;

#pragma mark - Helper methods

+ (nonnull UIColor *)life_colorWithHexValue:(NSUInteger)hexValue;
+ (nullable UIColor *)life_debugColorWithAlpha:(CGFloat)alpha __deprecated_msg("This should only be used for debug builds!");;

@end
