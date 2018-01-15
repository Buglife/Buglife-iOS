//
//  LIFEContainerModalDismissAnimator.m
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

#import "LIFEContainerModalDismissAnimator.h"
#import "LIFEImageEditorViewController.h"
#import "LIFEContainerViewController.h"
#import "UIViewController+LIFEAdditions.h"
#import "LIFEMacros.h"

@implementation LIFEContainerModalDismissAnimator

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    let containerVc = fromVc.life_containerViewController;
    let duration = [self transitionDuration:transitionContext];
    let oldFrame = fromVc.view.frame;
    let newFrame = CGRectOffset(oldFrame, 0, [UIScreen mainScreen].bounds.size.height);
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        fromVc.view.frame = newFrame;
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
