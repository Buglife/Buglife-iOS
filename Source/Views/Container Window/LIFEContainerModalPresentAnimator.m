//
//  LIFEContainerModalPresentAnimator.m
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

#import "LIFEContainerModalPresentAnimator.h"
#import "UIViewController+LIFEAdditions.h"
#import "LIFEContainerViewController.h"
#import "LIFEMacros.h"

@implementation LIFEContainerModalPresentAnimator

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    let toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    let containerVc = toVc.life_containerViewController;
    let containerView = transitionContext.containerView;
    let duration = [self transitionDuration:transitionContext];
    let newFrame = toVc.view.frame;
    let oldFrame = CGRectOffset(newFrame, 0, [UIScreen mainScreen].bounds.size.height);
    
    toVc.view.frame = oldFrame;
    [containerView addSubview:toVc.view];
    
    let damping = 1.0f;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:0 options:options animations:^{
        toVc.view.frame = newFrame;
        [containerVc setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

@end
