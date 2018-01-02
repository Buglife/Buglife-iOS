//
//  LIFEContainerViewController.m
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

#import "LIFEContainerViewController.h"
#import "LIFEAlertAnimator.h"
#import "LIFEContainerAlertToImageEditorAnimator.h"
#import "LIFEContainerTransitionContext.h"

@interface LIFEContainerViewController ()

@end

@implementation LIFEContainerViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return _statusBarHidden;
}

// This will attempt to animate in the new child view controller,
// in whatever way makes sense w/ respect to the existing child view
// controller (if any).
- (void)life_setChildViewController:(UIViewController *)childViewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    UIViewController *visibleViewController = self.childViewControllers.lastObject;
    
    if (visibleViewController == nil) {
        visibleViewController = self;
    }
    
    UIView *toView = childViewController.view;
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.view.bounds;
    [self addChildViewController:childViewController];
    
    id<UIViewControllerAnimatedTransitioning> animator;
    UIView *containerView = self.view;
    
    if ([LIFEContainerAlertToImageEditorAnimator canAnimateFromViewController:visibleViewController toViewController:childViewController]) {
        animator = [[LIFEContainerAlertToImageEditorAnimator alloc] init];
    } else if ([LIFEAlertAnimator canAnimateFromViewController:visibleViewController toViewController:childViewController]) {
        animator = [[LIFEAlertAnimator alloc] init];
    } else {
        [self.view addSubview:toView];
        [childViewController didMoveToParentViewController:self];
        return;
    }
    
    LIFEContainerTransitionContext *transitionContext = [[LIFEContainerTransitionContext alloc] initWithFromViewController:visibleViewController toViewController:childViewController containerView:containerView];
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        if (visibleViewController != self) {
            [visibleViewController.view removeFromSuperview];
            [visibleViewController removeFromParentViewController];
        }
        
        [childViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector(animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
    };
    
    [animator animateTransition:transitionContext];
}

- (void)life_dismissEverythingAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion
{
    completion();
}

@end
