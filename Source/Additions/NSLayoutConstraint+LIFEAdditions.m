//
//  NSLayoutConstraint+LIFEAdditions.m
//
//  Created by David Schukin on 12/4/15.
//
//

#import "NSLayoutConstraint+LIFEAdditions.h"

@implementation LIFENSLayoutConstraint

+ (NSLayoutConstraint *)life_constraintPinningView:(UIView *)view attribute:(NSLayoutAttribute)attribute constant:(CGFloat)constant
{
    return [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:constant];
}

+ (NSLayoutConstraint *)life_constraintPinningView:(UIView *)view1 toView:(UIView *)view2 attribute:(NSLayoutAttribute)attribute
{
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attribute multiplier:1 constant:0];
}

+ (NSLayoutConstraint *)life_constraintPinningView:(UIView *)view toSuperviewWithAttribute:(NSLayoutAttribute)attribute
{
    return [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:attribute multiplier:1 constant:0];
}

@end
