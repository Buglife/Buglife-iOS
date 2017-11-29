//
//  NSLayoutConstraint+LIFEAdditions.h
//
//  Created by David Schukin on 12/4/15.
//
//

#import <UIKit/UIKit.h>

@interface LIFENSLayoutConstraint : NSObject

+ (NSLayoutConstraint *)life_constraintPinningView:(UIView *)view1 toView:(UIView *)view2 attribute:(NSLayoutAttribute)attribute;

@end
