//
//  UIView+LIFEAdditions.h
//
//  Created by David Schukin on 2/6/16.
//
//

#import <UIKit/UIKit.h>

@protocol LIFEBlurrableView;

void LIFELoadCategoryFor_UIViewLIFEAdditions(void);

@interface UIView (LIFEAdditions)

@property (nonatomic, readonly) NSLayoutYAxisAnchor *life_safeAreaLayoutGuideBottomAnchor;
- (NSArray<LIFEBlurrableView> *)life_blurrableViews;
- (NSArray<UIView *> *)life_flattenedSubviewTree;
- (instancetype)life_firstResponder;
- (void)life_makeEdgesEqualTo:(UIView *)view;
- (void)life_makeEdgesEqualTo:(UIView *)view withInset:(CGFloat)inset;
- (void)life_makeEdgesEqualTo:(UIView *)view withInsets:(UIEdgeInsets)insets;

@end
