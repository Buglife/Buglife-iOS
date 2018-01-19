//
//  LIFEContainerAlertToImageEditorAnimator.m
//  Copyright (C) 2018 Buglife, Inc.
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

#import "LIFEContainerAlertToImageEditorAnimator.h"
#import "LIFEAlertController.h"
#import "LIFEAlertView.h"
#import "LIFEImageEditorViewController.h"
#import "LIFEImageEditorView.h"
#import "LIFEScreenshotAnnotatorView.h"
#import "LIFENavigationController.h"
#import "LIFEMacros.h"

let kAnimationMultiplier = 1.0f; // To test slowing down animations
let kInitialAnimationDuration = (0.75f * kAnimationMultiplier);
let kSecondAnimationDelay = (0.25f * kAnimationMultiplier);
let kSecondAnimationDuration = (0.75f * kAnimationMultiplier);

@implementation LIFEContainerAlertToImageEditorAnimator

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    LIFEAlertController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    LIFENavigationController *toNavVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    BOOL hostAppStatusBarWasHidden = [UIApplication sharedApplication].statusBarHidden;
    UIStatusBarStyle hostAppStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    // HORRIBLE HACK: (well, maybe not that bad, cause UIKit status bar
    // things are often difficult to work around.)
    // 1. So we need to call setNeedsStatusBarAppearanceUpdate on the nav VC
    // before we add subviews & lay them out, so that the last frames of the
    // animation are laid out correctly (i.e. with a status bar in place),
    // and that the views don't suddenly "jump" 20px once the animation is
    // complete.
    [toNavVc setNeedsStatusBarAppearanceUpdate];
    
    // 2. Add & layout the subviews
    UIView *containerView = transitionContext.containerView;
    [containerView addSubview:toNavVc.view];
    LIFEAssertIsKindOfClass(fromVc, LIFEAlertController);
    LIFEAssertIsKindOfClass(toNavVc, LIFENavigationController);
    NSParameterAssert([toNavVc isKindOfClass:[LIFENavigationController class]]);
    
    let toVc = (LIFEImageEditorViewController *)toNavVc.visibleViewController;
    LIFEAssertIsKindOfClass(toVc, LIFEImageEditorViewController);
    
    CGRect imageViewFrameStart = [containerView convertRect:fromVc.alertView.imageView.frame fromView:fromVc.alertView.imageView.superview];
    LIFEImageEditorView *imageEditorView = toVc.imageEditorView;
    [toNavVc.view layoutIfNeeded];
    [imageEditorView layoutIfNeeded];
    CGRect imageViewFrameEnd = [containerView convertRect:imageEditorView.sourceImageView.frame fromView:imageEditorView.sourceImageView.superview];
    CGFloat borderWidth = [LIFEImageEditorView imageBorderWidth];
    CGRect borderViewFrameStart = CGRectInset(imageViewFrameStart, -borderWidth, -borderWidth);
    CGRect borderViewFrameEnd = CGRectInset(imageViewFrameEnd, -borderWidth, -borderWidth);
    
    // Create a temporary border view for the interim of the transition.
    // We can't rely on UIView.layer.border, because this will expand/contract
    // and result in a weird flicker during a spring transition. By having
    // a separate borderView that is always 2pt outset from the imageView,
    // the border will hav ethe appearance of always being 2pt thick during
    // the transition.
    UIView *borderView = [[UIView alloc] init];
    borderView.backgroundColor = [LIFEImageEditorView imageBorderColor];
    borderView.frame = borderViewFrameStart;
    [containerView addSubview:borderView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:fromVc.alertView.imageView.image];
    [containerView addSubview:imageView];
    imageView.frame = imageViewFrameStart;
    
    [toVc.imageEditorView prepareFirstPresentationTransition];
    [fromVc prepareExpandToDismissTransition];
    
    fromVc.alertView.imageView.hidden = YES;
    
    // 3. Temporarily "hide" the status bar on LIFENavigationController if needed,
    // so that we can immediately call -setNeedsStatusBarAppearanceUpdate
    // again, so that the beginning of the animation functions correctly
    [toNavVc enableStatusBarOverrideHidden:hostAppStatusBarWasHidden style:hostAppStatusBarStyle];
    [toNavVc setNeedsStatusBarAppearanceUpdate];
    
    // 4. Reset LIFENavigationController's statusBarHidden property
    [toNavVc disableStatusBarOverride];
    
    let damping = 0.6f;
    let initialSpringVelocity = 0.0f;
    
    let navBarTransform = CGAffineTransformMakeTranslation(0, -100);
    toNavVc.navigationBar.transform = navBarTransform;
    toNavVc.navigationBar.alpha = 0;
    
    let newAlertViewBackgroundColor = imageEditorView.backgroundView.backgroundColor;
    
    [UIView animateWithDuration:kInitialAnimationDuration delay:0 usingSpringWithDamping:damping initialSpringVelocity:initialSpringVelocity options:0 animations:^{
        [fromVc.alertView setBackgroundViewBackgroundColor:newAlertViewBackgroundColor];
        [fromVc.alertView layoutIfNeeded];
        [fromVc.alertView performDismissTransition];
        imageView.frame = imageViewFrameEnd;
        borderView.frame = borderViewFrameEnd;
        // 5. Animate in the status bar
        [toNavVc setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        [toVc.imageEditorView completeFirstPresentationTransition];
        [imageView removeFromSuperview];
        [borderView removeFromSuperview];
    }];
    
    // We need to use a dispatch_after instead of the UIView delay
    // block because we're changing constraints after a delay, *then*
    // animating them
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSecondAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toVc.imageEditorView prepareSecondPresentationTransition];
        
        [UIView animateWithDuration:kSecondAnimationDuration delay:0 usingSpringWithDamping:damping initialSpringVelocity:initialSpringVelocity options:0 animations:^{
            toNavVc.navigationBar.transform = CGAffineTransformIdentity;
            [toVc.imageEditorView performSecondPresentationTransition];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    });
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext
{
    return kSecondAnimationDelay + kSecondAnimationDuration;
}

@end
