//
//  LIFEContainerTransitionContext.h
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

#import <UIKit/UIKit.h>

@interface LIFEContainerTransitionContext : NSObject <UIViewControllerContextTransitioning>

/**
 * If presenting a view controller for the first time within a parent,
 * the containerView should be the parent's view.
 * If moving from one view controller to another, the containterView
 * should be fromVc's view's superView.
 */
- (nonnull instancetype)initWithFromViewController:(nullable UIViewController *)fromVc toViewController:(nullable UIViewController *)toVc containerView:(nonnull UIView *)containerView;

@property (nonatomic, copy) void (^ _Nullable completionBlock)(BOOL didComplete);
@property (nonatomic, getter=isAnimated) BOOL animated;
@property (nonatomic, getter=isInteractive) BOOL interactive;
@property (nonatomic, readonly) UIModalPresentationStyle presentationStyle;
@property (nonatomic, readonly, nonnull) UIView *containerView;

@end
