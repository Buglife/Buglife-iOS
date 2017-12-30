//
//  LIFEToolButton.h
//  Buglife
//
//  Created by David Schukin on 12/28/17.
//

#import <UIKit/UIKit.h>

@interface LIFEToolButton : UIControl

@property (nonnull, nonatomic) UIImageView *imageView;
@property (nonnull, nonatomic) UILabel *titleView;

- (void)setTintColor:(nonnull UIColor *)tintColor forState:(UIControlState)state;

@end
