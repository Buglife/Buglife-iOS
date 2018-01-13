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
#import "LIFEMacros.h"

static let kAnimationDuratioMultiplier = 1.0f;
static let kAnticipationScale = 1.1f;
static let kAnticipationDuration = (0.15f * kAnimationDuratioMultiplier);
static let kSpringDuration = (0.3f * kAnimationDuratioMultiplier);

@implementation LIFEWindowBlindsAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    let fromVc = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    let normalHeight = CGRectGetHeight(fromVc.view.frame);
    let scaledHeight = normalHeight * kAnticipationScale;
    let heightDelta = scaledHeight - normalHeight;
    CGAffineTransform anticipationTransform = CGAffineTransformMakeScale(1, kAnticipationScale);
    anticipationTransform = CGAffineTransformTranslate(anticipationTransform, 0, heightDelta);
    
    let heightMultiplier = 1.25f;
    CGAffineTransform finalTransform = CGAffineTransformMakeTranslation(0, -(normalHeight * heightMultiplier));
    
    [UIView animateWithDuration:kAnticipationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromVc.view.transform = anticipationTransform;
    } completion:^(BOOL finished) {
        // This is an awful hack to get around a bug where between transitions, the view frame changes to accomodate
        // the now-gone nav controller's navigation bar
        let navigationBarHeight = 64.0f;
        CGAffineTransform hackedTransform = CGAffineTransformTranslate(anticipationTransform, 0, -(navigationBarHeight * heightMultiplier));
        fromVc.view.transform = hackedTransform;
        [UIView animateWithDuration:kSpringDuration delay:0 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            fromVc.view.transform = finalTransform;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return kAnticipationDuration + kSpringDuration;
}

@end
