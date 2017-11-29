//
//  UITextView+LIFEAdditions.h
//  Pods
//
//  Created by David Schukin on 11/17/15.
//
//

#import <UIKit/UIKit.h>

@interface LIFEUITextView : NSObject

+ (CGFloat)textView:(UITextView *)textView boundingHeightWithWidth:(CGFloat)width;

// Used for when you want to calculate the height of a textView using its
// textContainer & font attributes, but with a different string & without
// actually replacing the textView's string
//
// @deprecated use boundingHeightForText:width:lineFragmentPadding:font:
+ (CGFloat)textView:(UITextView *)textView boundingHeightWithWidth:(CGFloat)width replacementText:(NSString *)replacementText;

+ (CGFloat)boundingHeightForText:(NSString *)text width:(CGFloat)width font:(UIFont *)font;

@end
