//
//  UITextView+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 11/17/15.
//
//

#import "UITextView+LIFEAdditions.h"

static const CGFloat kDefaultLineFragmentPadding = 5; // the default according to apple docs

@implementation LIFEUITextView

+ (CGFloat)textView:(UITextView *)textView boundingHeightWithWidth:(CGFloat)width
{
    CGFloat boundsMinusPadding = width - (2.0 * textView.textContainer.lineFragmentPadding);
    return [self textView:textView boundingRectWithSize:CGSizeMake(boundsMinusPadding, CGFLOAT_MAX)].height;
}

+ (CGSize)textView:(UITextView *)textView boundingRectWithSize:(CGSize)size
{
    NSDictionary *attributes = @{ NSFontAttributeName : textView.font };
    CGRect rect = [textView.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size;
}

+ (CGFloat)textView:(UITextView *)textView boundingHeightWithWidth:(CGFloat)width replacementText:(NSString *)replacementText
{
    return [self boundingHeightForText:replacementText width:width lineFragmentPadding:textView.textContainer.lineFragmentPadding font:textView.font];
}

+ (CGFloat)boundingHeightForText:(NSString *)text width:(CGFloat)width font:(UIFont *)font
{
    return [self boundingHeightForText:text width:width lineFragmentPadding:kDefaultLineFragmentPadding font:font];
}

+ (CGFloat)boundingHeightForText:(NSString *)text width:(CGFloat)width lineFragmentPadding:(CGFloat)lineFragmentPadding font:(UIFont *)font
{
    CGFloat boundsMinusPadding = width - (2.0 * lineFragmentPadding);
    CGSize size = CGSizeMake(boundsMinusPadding, CGFLOAT_MAX);
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size.height;
}

@end
