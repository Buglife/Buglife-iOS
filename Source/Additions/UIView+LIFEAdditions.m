//
//  UIView+LIFEAdditions.m
//
//  Created by David Schukin on 2/6/16.
//
//

#import "UIView+LIFEAdditions.h"
#import "Buglife.h"
#import "LIFECompatibilityUtils.h"
#import "LIFEMacros.h"

@implementation UIView (LIFEAdditions)

+ (void)life_loadCategory_UIViewLIFEAdditions { }

- (NSLayoutYAxisAnchor *)life_safeAreaLayoutGuideBottomAnchor
{
    // We need to check at runtime whether we're running iOS 11
    // to use the new safe area layout guides, however we still
    // need to support Xcode 8, so we can't use the latest & greatest
    // @availability checks.
    if ([LIFECompatibilityUtils isiOS11OrHigher]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        let guide = self.safeAreaLayoutGuide;
#pragma clang diagnostic pop
        return guide.bottomAnchor;
    } else {
        return self.bottomAnchor;
    }
}

- (NSArray<LIFEBlurrableView> *)life_blurrableViews
{
    NSMutableArray<LIFEBlurrableView> *blurrableViews = [NSMutableArray<LIFEBlurrableView> new];
    
    for (UIView *view in [self life_flattenedSubviewTree]) {
        if ([view conformsToProtocol:@protocol(LIFEBlurrableView)]) {
            UIView<LIFEBlurrableView> *blurrableView = (UIView<LIFEBlurrableView> *)view;
            
            if ([blurrableView respondsToSelector:@selector(buglifeShouldBlurForScreenCapture)]) {
                BOOL shouldBlur = [blurrableView buglifeShouldBlurForScreenCapture] && (blurrableView.isHidden == NO) && (blurrableView.alpha > 0);
                
                if (shouldBlur) {
                    [blurrableViews addObject:blurrableView];
                }
            } else {
                LIFELogExtError(@"View %@ adopts protocol %@, but does not implement required method %@. This view will NOT be blurred for screenshots.", view, NSStringFromProtocol(@protocol(LIFEBlurrableView)), NSStringFromSelector(@selector(buglifeShouldBlurForScreenCapture)));
            }
        }
    }
    
    return [NSArray<LIFEBlurrableView> arrayWithArray:blurrableViews];
}

- (NSArray<UIView *> *)life_flattenedSubviewTree
{
    NSMutableArray *subviews = [[NSMutableArray alloc] initWithCapacity:self.subviews.count];
    
    for (UIView *subview in self.subviews) {
        [subviews addObject:subview];
        [subviews addObjectsFromArray:[subview life_flattenedSubviewTree]];
    }
    
    return subviews;
}

- (instancetype)life_firstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    
    for (UIView *subview in self.subviews) {
        UIView *responder = [subview life_firstResponder];
        
        if (responder) {
            return responder;
        }
    }
    
    return nil;
}

#pragma mark - Auto Layout

- (void)life_makeEdgesEqualTo:(UIView *)view
{
    [self life_makeEdgesEqualTo:view withInset:0];
}

- (void)life_makeEdgesEqualTo:(UIView *)view withInset:(CGFloat)inset
{
    UIEdgeInsets insets = UIEdgeInsetsMake(inset, inset, inset, inset);
    [self life_makeEdgesEqualTo:view withInsets:insets];
}

- (void)life_makeEdgesEqualTo:(UIView *)view withInsets:(UIEdgeInsets)insets
{
    [NSLayoutConstraint activateConstraints:@[
                                              [self.topAnchor constraintEqualToAnchor:view.topAnchor constant:insets.top],
                                              [self.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:-insets.right],
                                              [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-insets.bottom],
                                              [self.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:insets.left]
                                              ]];
}

@end

void LIFELoadCategoryFor_UIViewLIFEAdditions() {
    [UIView life_loadCategory_UIViewLIFEAdditions];
}
