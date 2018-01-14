//
//  LIFEContainerTransitionContext.m
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

#import "LIFEContainerTransitionContext.h"

@interface LIFEContainerTransitionContext ()

@property (nonatomic, nonnull) NSDictionary<UITransitionContextViewKey, UIViewController *> *privateViewControllers;
@property (nonatomic) UIModalPresentationStyle presentationStyle;
@property (nonatomic) UIView *containerView;

@end

@implementation LIFEContainerTransitionContext

@synthesize transitionWasCancelled;
@synthesize targetTransform;

#pragma mark - Public methods

- (instancetype)initWithFromViewController:(nullable UIViewController *)fromVc toViewController:(nullable UIViewController *)toVc containerView:(nonnull UIView *)containerView
{
    self = [super init];
    if (self) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = containerView;
        
        NSMutableDictionary *privateViewControllers = [NSMutableDictionary dictionary];
        
        if (fromVc) {
            privateViewControllers[UITransitionContextFromViewControllerKey] = fromVc;
        }
        
        if (toVc) {
            privateViewControllers[UITransitionContextToViewControllerKey] = toVc;
        }
        
        _privateViewControllers = [NSDictionary dictionaryWithDictionary:privateViewControllers];
    }
    return self;
}

#pragma mark - UIViewControllerContextTransitioning

- (void)cancelInteractiveTransition { }

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock(didComplete);
    }
}

- (CGRect)finalFrameForViewController:(nonnull UIViewController *)vc {
    return _containerView.bounds;
}

- (void)finishInteractiveTransition { }

- (CGRect)initialFrameForViewController:(nonnull UIViewController *)vc {
    return _containerView.bounds;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete { }

- (nullable __kindof UIViewController *)viewControllerForKey:(nonnull UITransitionContextViewControllerKey)key {
    return _privateViewControllers[key];
}

- (nullable __kindof UIView *)viewForKey:(nonnull UITransitionContextViewKey)key
{
    return _privateViewControllers[key].view;
}


@end
