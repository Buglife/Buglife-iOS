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

let kInitialAlertViewScale = 0.5;

@implementation LIFEAlertAnimator

+ (BOOL)canAnimateFromViewController:(nonnull UIViewController *)fromVc toViewController:(nonnull UIViewController *)toVc
{
    return [toVc isKindOfClass:[LIFEAlertController class]];
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
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

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

@end
