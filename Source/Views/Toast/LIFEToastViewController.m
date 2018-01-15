//
//  LIFEToastViewController.m
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

#import "LIFEToastViewController.h"
#import "LIFEToastView.h"
#import "LIFEMacros.h"

static let kPaddingX = 10.0f;
static let kPaddingY = 10.0f;
static let kHiddenToastBottomConstraintConstant = 100.0f;

@interface LIFEToastViewController ()

@property (nonnull, nonatomic) LIFEToastView *toastView;
@property (nonnull, nonatomic) NSLayoutConstraint *bottomConstraint;
@property (nonnull, nonatomic) NSTimer *dismissTimer;
@property (nonnull, nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) CGPoint panGestureStartLocation;

@end

@implementation LIFEToastViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _toastView = [[LIFEToastView alloc] init];
    _toastView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_toastView];
    [NSLayoutConstraint activateConstraints:@[
        [_toastView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kPaddingX],
        [_toastView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kPaddingX]
        ]];
    
    _bottomConstraint = [_toastView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:kHiddenToastBottomConstraintConstant];
    _bottomConstraint.active = YES;
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    [_toastView addGestureRecognizer:_panGesture];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return _statusBarHidden;
}

- (BOOL)modalPresentationCapturesStatusBarAppearance
{
    return NO;
}

#pragma mark - Animation

- (void)prepareAnimateIn
{
    _bottomConstraint.constant = -kPaddingY;
}

- (void)animateIn
{
    [self.view layoutIfNeeded];
}

- (void)didAnimateIn
{
    [self _startTimer];
}

#pragma mark - Private

- (void)_handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    let location = [panGesture locationInView:self.view];
    let velocity = [panGesture velocityInView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            _panGestureStartLocation = location;
            [self _cancelTimer];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat deltaY = location.y - _panGestureStartLocation.y;
            
            if (deltaY < 0) {
                let verticalLimit = 150.0f;
                let absY = fabs(deltaY) + verticalLimit;
                let constrainedY = verticalLimit * (1.0f * log10(absY / verticalLimit));
                deltaY = -constrainedY;
            }
            
            _bottomConstraint.constant = (-kPaddingY) + deltaY;
            [self.view layoutIfNeeded];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            if (velocity.y > 20.0f) {
                [self _dismissWithVelocity:20.0f];
            } else {
                [self _resetPosition];
            }
            
            break;
        default:
            break;
    }
}

- (void)_resetPosition
{
    [self prepareAnimateIn];
    
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.9 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self animateIn];
    } completion:^(BOOL finished) {
        [self didAnimateIn];
    }];
}

- (void)_cancelTimer
{
    [_dismissTimer invalidate];
    _dismissTimer = nil;
}

- (void)_startTimer
{
    [self _cancelTimer];
    _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(_timerEnded) userInfo:nil repeats:NO];
}

- (void)_timerEnded
{
    [self _dismissWithVelocity:0.9];
}

- (void)_dismissWithVelocity:(CGFloat)velocity
{
    [_dismissTimer invalidate];
    _dismissTimer = nil;
    
    _bottomConstraint.constant = kHiddenToastBottomConstraintConstant;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:velocity options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.dismissHandler();
    }];
}

@end
