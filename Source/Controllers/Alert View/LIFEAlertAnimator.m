//
//  LIFEAlertAnimator.m
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

#import "LIFEAlertAnimator.h"
#import "LIFEAlertController.h"
#import "LIFEAlertView.h"
#import "LIFEMacros.h"

let kInitialAlertViewScale = 1.2;
let kFinalAlertViewScaleWhenAnimatingOut = 0.8;

@interface LIFEAlertAnimator ()

@property (nonatomic) BOOL animateIn;

@end

@implementation LIFEAlertAnimator

+ (nonnull instancetype)presentationAnimator
{
    LIFEAlertAnimator *animator = [[LIFEAlertAnimator alloc] init];
    animator.animateIn = YES;
    return animator;
}

+ (nonnull instancetype)dismissAnimator
{
    LIFEAlertAnimator *animator = [[LIFEAlertAnimator alloc] init];
    animator.animateIn = NO;
    return animator;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    if (_animateIn) {
        [self _animateInTransition:transitionContext];
    } else {
        [self _animateOutTransition:transitionContext];
    }
}

- (void)_animateInTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    let toVc = (LIFEAlertController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    let containerView = transitionContext.containerView;
    let duration = [self transitionDuration:transitionContext];
    [containerView addSubview:toVc.view];
    
    [toVc setDarkOverlayHidden:YES];
    toVc.alertView.alpha = 0;
    toVc.alertView.transform = CGAffineTransformMakeScale(kInitialAlertViewScale, kInitialAlertViewScale);
    
    CGFloat damping = 0.6;
    CGFloat initialVelocity = 0;
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:initialVelocity options:0 animations:^{
        [toVc setDarkOverlayHidden:NO];
        toVc.alertView.alpha = 1;
        toVc.alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)_animateOutTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    let fromVc = (LIFEAlertController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    let duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        [fromVc setDarkOverlayHidden:YES];
        fromVc.alertView.alpha = 0;
        fromVc.alertView.transform = CGAffineTransformMakeScale(kFinalAlertViewScaleWhenAnimatingOut, kFinalAlertViewScaleWhenAnimatingOut);;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    if (_animateIn) {
        return 0.5;
    } else {
        return 0.2;
    }
}

@end
