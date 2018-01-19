//
//  LIFEWindowBlindsAnimator.m
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

#import "LIFEWindowBlindsAnimator.h"
#import "UIView+LIFEAdditions.h"
#import "UIViewController+LIFEAdditions.h"
#import "LIFEToastController.h"
#import "LIFEContainerViewController.h"
#import "LIFEMacros.h"

static let kAnimationDuratioMultiplier = 1.0f;
static let kAnticipationScale = 1.1f;
static let kAnticipationDuration = (0.15f * kAnimationDuratioMultiplier);
static let kSpringDuration = (0.3f * kAnimationDuratioMultiplier);
static let kToastDelay = (kSpringDuration / 2.0);
static let kToastDuration = (0.3f * kAnimationDuratioMultiplier);
static let kToastSuccessFeedbackDelay = (kToastDelay * 0.75f);

@interface LIFEWindowBlindsAnimator ()

@property (nonatomic) NSLayoutConstraint *centerYConstraint;
@property (nonatomic) NSLayoutConstraint *heightConstraint;

@end

@implementation LIFEWindowBlindsAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    let fromVc = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    let toVc = (LIFEToastController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    let containerVc = fromVc.life_containerViewController;
    let containerView = transitionContext.containerView;
    let normalHeight = CGRectGetHeight(fromVc.view.frame);
    let scaledHeight = normalHeight * kAnticipationScale;
    let heightDelta = scaledHeight - normalHeight;
    CGAffineTransform anticipationTransform = CGAffineTransformMakeScale(1, kAnticipationScale);
    anticipationTransform = CGAffineTransformTranslate(anticipationTransform, 0, heightDelta);

    let heightMultiplier = 1.25f;
    CGAffineTransform finalTransform = CGAffineTransformMakeTranslation(0, -(normalHeight * heightMultiplier));
    
    [containerView addSubview:toVc.view];

    [UIView animateWithDuration:kAnticipationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromVc.view.transform = anticipationTransform;
    } completion:^(BOOL finished) {
        // This is an awful hack to get around a bug where between transitions, the view frame changes to accomodate
        // the now-gone nav controller's navigation bar
        let navigationBarHeight = 64.0f;
        CGAffineTransform hackedTransform = CGAffineTransformTranslate(anticipationTransform, 0, -(navigationBarHeight * heightMultiplier));
        fromVc.view.transform = hackedTransform;
        UIViewAnimationOptions options = (UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState);
        [UIView animateWithDuration:kSpringDuration delay:0 options:options animations:^{
            fromVc.view.transform = finalTransform;
            [containerVc setNeedsStatusBarAppearanceUpdate];
        } completion:nil];
        
        // The toast should lag by a tiny bit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kToastDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toVc prepareAnimateIn];
            
            [UIView animateWithDuration:kToastDuration delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.9 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) animations:^{
                [toVc animateIn];
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                [toVc didAnimateIn];
            }];
        });
        
        // Success haptic feedback needs to be timed just right, kinda between animations
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kToastSuccessFeedbackDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toVc generateSuccessFeedback];
        });
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return kAnticipationDuration + kToastDelay + kToastDuration;
}

@end
