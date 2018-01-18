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
#import "LIFEAlertController.h"
#import "LIFEContainerAlertToImageEditorAnimator.h"
#import "LIFEContainerModalDismissAnimator.h"
#import "LIFEImageEditorViewController.h"
#import "LIFEContainerTransitionContext.h"
#import "LIFENavigationController.h"
#import "LIFEWindowBlindsAnimator.h"
#import "LIFEMacros.h"
#import "LIFEToastController.h"
#import "LIFEContainerModalPresentAnimator.h"

@interface LIFEPassThroughView : UIView
@end

@interface LIFEContainerViewController ()

@property (nonnull, nonatomic) LIFEPassThroughView *passThroughView;

@end

@implementation LIFEContainerViewController

- (void)loadView
{
    self.view = [[LIFEPassThroughView alloc] init];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ([self _visibleViewControllerCapturesStatusBarAppearance]) {
        return [self.visibleViewController preferredStatusBarStyle];
    }
    
    return _statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    if ([self _visibleViewControllerCapturesStatusBarAppearance]) {
        return [self.visibleViewController prefersStatusBarHidden];
    }
    
    return _statusBarHidden;
}

// If you'd like your child view controller to set the status
// bar appearance, implement -modalPresentationCapturesStatusBarAppearance
// in that child view controller, along with -preferredStatusBarStyle
// and -prefersStatusBarHidden. Otherwise, LIFEContainerViewController
// will simply use its own properties, which should match the host application
// (giving the appearance of being "transparent").
- (BOOL)_visibleViewControllerCapturesStatusBarAppearance
{
    if (self.visibleViewController) {
        return [self.visibleViewController modalPresentationCapturesStatusBarAppearance];
    }
    
    return NO;
}

- (nullable UIViewController *)visibleViewController
{
    return self.childViewControllers.lastObject;
}

- (void)life_presentViewController:(nonnull UIViewController *)newViewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    UIViewController *visibleViewController = self.visibleViewController;
    id<UIViewControllerAnimatedTransitioning> animator;
    
    // If an alert controller is already visible, we may have to have a special
    // transition into the new view controller
    if ([visibleViewController isKindOfClass:[LIFEAlertController class]]) {
        if ([newViewController isKindOfClass:[LIFENavigationController class]]) {
            let nav = (LIFENavigationController *)newViewController;
            
            if ([nav.visibleViewController isKindOfClass:[LIFEImageEditorViewController class]]) {
                // If we're transitioning from an alert to the image editor,
                // we want this to be one seamless transition
                animator = [[LIFEContainerAlertToImageEditorAnimator alloc] init];
                [self _performTransitionFromViewController:visibleViewController toViewController:nav withAnimator:animator completion:completion];
                return;
            }
        }
        
        // If we're transitioning from an alert to any other view controller,
        // we need to dismiss the alert first before we presnt the new view controller
        [self _dismissCurrentViewControllerAndPresentViewController:newViewController animated:animated completion:completion];
        return;
    }
    
    if ([newViewController isKindOfClass:[LIFEAlertController class]]) {
        // For a new alert, have a special presentation animation
        animator = [LIFEAlertAnimator presentationAnimator];
    } else {
        // For anything else, just use our default modal presentation animation
        animator = [[LIFEContainerModalPresentAnimator alloc] init];
    }
    
    [self _performTransitionFromViewController:visibleViewController toViewController:newViewController withAnimator:animator completion:completion];
}

- (void)_performTransitionFromViewController:(nonnull UIViewController *)fromViewController toViewController:(nonnull UIViewController *)toViewController withAnimator:(nonnull id<UIViewControllerAnimatedTransitioning>)animator completion:(void (^)(void))completion
{
    UIView *toView = toViewController.view;
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.view.bounds;
    [self addChildViewController:toViewController];
    
    UIView *containerView = self.view;
    LIFEContainerTransitionContext *transitionContext = [[LIFEContainerTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController containerView:containerView];
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        if (fromViewController != self) {
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
        }
        
        [toViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector(animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        
        if (completion) {
            completion();
        }
    };
    
    [animator animateTransition:transitionContext];
}

- (void)life_setChildViewController:(UIViewController *)childViewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    UIViewController *visibleViewController = self.visibleViewController;

    if ([visibleViewController isKindOfClass:[LIFENavigationController class]]) {
        let navVC = (LIFENavigationController *)visibleViewController;
        [navVC setViewControllers:@[childViewController] animated:animated];
        return;
    }
    
    NSAssert(NO, @"Attempting to set child view controller, but there's no navigation controller yet. Wut?");

    UIView *toView = childViewController.view;
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.view.bounds;
    [self addChildViewController:childViewController];
    [self.view addSubview:toView];
    [childViewController didMoveToParentViewController:self];
    return;
}

- (void)_dismissCurrentViewControllerAndPresentViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion
{
    __weak typeof(self) weakSelf = self;
    
    [self life_dismissEverythingAnimated:animated completion:^{
        __strong LIFEContainerViewController *strongSelf = weakSelf;
        
        if (strongSelf) {
            [strongSelf life_presentViewController:viewController animated:animated completion:completion];
        }
    }];
}

- (void)life_dismissEverythingAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion
{
    UIViewController *visibleViewController = self.childViewControllers.lastObject;
    id<UIViewControllerAnimatedTransitioning> animator = [self _animatorToDismissViewController:visibleViewController];
    
    if (animator) {
        LIFEContainerTransitionContext *transitionContext = [[LIFEContainerTransitionContext alloc] initWithFromViewController:visibleViewController toViewController:self containerView:self.view];
        transitionContext.animated = YES;
        transitionContext.interactive = NO;
        transitionContext.completionBlock = ^(BOOL didComplete) {
            [visibleViewController.view removeFromSuperview];
            [visibleViewController removeFromParentViewController];
            
            if ([animator respondsToSelector:@selector(animationEnded:)]) {
                [animator animationEnded:didComplete];
            }
            
            if (completion) {
                completion();
            }
        };
        
        [visibleViewController willMoveToParentViewController:nil];
        [animator animateTransition:transitionContext];
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)dismissWithWindowBlindsAnimation:(BOOL)animated showToast:(nullable LIFEToastController *)toastViewController completion:(void (^ __nullable)(void))completion
{
    let fromVc = self.visibleViewController;
    
    if (toastViewController) {
        toastViewController.dismissHandler = completion;
        UIView *toView = toastViewController.view;
        toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        toView.frame = self.view.bounds;
        [self addChildViewController:toastViewController];
    }
    
    id<UIViewControllerAnimatedTransitioning> animator = [[LIFEWindowBlindsAnimator alloc] init];
    
    UIView *containerView = self.view;
    LIFEContainerTransitionContext *transitionContext = [[LIFEContainerTransitionContext alloc] initWithFromViewController:fromVc toViewController:toastViewController containerView:containerView];
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        if (fromVc != self) {
            [fromVc.view removeFromSuperview];
            [fromVc removeFromParentViewController];
        }
        
        [toastViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector(animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        
        if (toastViewController == nil) {
            completion();
        }
    };
    
    [animator animateTransition:transitionContext];
}

- (nullable id<UIViewControllerAnimatedTransitioning>)_animatorFromViewController:(nullable UIViewController *)fromVC toViewController:(nonnull UIViewController *)toVC
{
    if ([toVC isKindOfClass:[LIFEAlertController class]]) {
        return [LIFEAlertAnimator presentationAnimator];
    }
    
    if ([fromVC isKindOfClass:[LIFEAlertController class]] && [toVC isKindOfClass:[LIFENavigationController class]]) {
        let nav = (LIFENavigationController *)toVC;
        
        if ([nav.visibleViewController isKindOfClass:[LIFEImageEditorViewController class]]) {
            return [[LIFEContainerAlertToImageEditorAnimator alloc] init];
        }
    }
    
    BOOL isFirstChildViewController = (fromVC == nil);
    
    if (isFirstChildViewController) {
        return [[LIFEContainerModalPresentAnimator alloc] init];
    }
    
    return nil;
}

- (nullable id<UIViewControllerAnimatedTransitioning>)_animatorToDismissViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[LIFEAlertController class]]) {
        return [LIFEAlertAnimator dismissAnimator];
    }
    
    return [[LIFEContainerModalDismissAnimator alloc] init];
}

@end

@implementation LIFEPassThroughView

// Unless a touch event hits an actual subview,
// let it pass through to whatever's behind. This allows things like
// LIFEToastView to remain onscreen while allowing the host app to
// receive touches.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

@end
