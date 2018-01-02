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
#import "LIFEMacros.h"

let kInitialAnimationDuration = 0.75f;
let kSecondAnimationDelay = 0.25f;
let kSecondAnimationDuration = 0.75f;

@implementation LIFEContainerAlertToImageEditorAnimator

+ (BOOL)canAnimateFromViewController:(nonnull UIViewController *)fromVc toViewController:(nonnull UIViewController *)toVc
{
    return [fromVc isKindOfClass:[LIFEAlertController class]] && [toVc isKindOfClass:[LIFEImageEditorViewController class]];
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    LIFEAlertController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    LIFEImageEditorViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    [containerView addSubview:toVc.view];
    
    CGRect imageViewFrameStart = [containerView convertRect:fromVc.alertView.imageView.frame fromView:fromVc.alertView.imageView.superview];
    LIFEImageEditorView *imageEditorView = toVc.imageEditorView;
    [imageEditorView layoutIfNeeded];
    CGRect imageViewFrameEnd = [containerView convertRect:imageEditorView.sourceImageView.frame fromView:imageEditorView.sourceImageView.superview];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:fromVc.alertView.imageView.image];
    imageView.layer.borderColor = [UIColor blackColor].CGColor;
    imageView.layer.borderWidth = 1;
    [containerView addSubview:imageView];
    imageView.frame = imageViewFrameStart;
    
    [toVc.imageEditorView prepareFirstPresentationTransition];
    [fromVc animateAlertViewBackgroundOut];
    
    fromVc.alertView.imageView.hidden = YES;
    
    let damping = 0.6f;
    let initialSpringVelocity = 0.0f;
    
    [UIView animateWithDuration:kInitialAnimationDuration delay:0 usingSpringWithDamping:damping initialSpringVelocity:initialSpringVelocity options:0 animations:^{
        [fromVc.alertView layoutIfNeeded];
        [fromVc.alertView animateContentsOut];
        imageView.frame = imageViewFrameEnd;
    } completion:^(BOOL finished) {
        [toVc.imageEditorView completeFirstPresentationTransition];
        [imageView removeFromSuperview];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSecondAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toVc.imageEditorView prepareSecondPresentationTransition];
        
        [UIView animateWithDuration:kSecondAnimationDuration delay:0 usingSpringWithDamping:damping initialSpringVelocity:initialSpringVelocity options:0 animations:^{
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
