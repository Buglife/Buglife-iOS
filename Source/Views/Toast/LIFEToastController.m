//
//  LIFEToastController.m
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

#import "LIFEToastController.h"
#import "LIFEToastControllerView.h"
#import "LIFEToastView.h"
#import "LIFEMacros.h"

let kToastDisplayDuration = 2.0f;

@interface LIFEToastController ()

@property (nonnull, nonatomic, readonly) LIFEToastControllerView *toastControllerView;
@property (nonatomic) NSTimer *dismissTimer;
@property (nonnull, nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) CGPoint panGestureStartLocation;
@property (nullable, nonatomic) UINotificationFeedbackGenerator *feedbackGenerator NS_AVAILABLE_IOS(10_0);

@end

@implementation LIFEToastController

#pragma mark - UIViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (@available(iOS 10.0, *)) {
            _feedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
        }
        
        [_feedbackGenerator prepare];
    }
    return self;
}

- (void)loadView
{
    self.view = [[LIFEToastControllerView alloc] init];
}

- (LIFEToastControllerView *)toastControllerView
{
    return (LIFEToastControllerView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    [self.toastControllerView.toastView addGestureRecognizer:_panGesture];
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
    self.toastControllerView.toastViewOffsetY = 0;
}

- (void)animateIn
{
    [self.view layoutIfNeeded];
}

- (void)didAnimateIn
{
    [self _startTimer];
}

- (void)generateSuccessFeedback
{
    [_feedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
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
            
            self.toastControllerView.toastViewOffsetY = deltaY;
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
        [self _startTimer];;
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
    _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:kToastDisplayDuration target:self selector:@selector(_timerEnded) userInfo:nil repeats:NO];
}

- (void)_timerEnded
{
    [self _dismissWithVelocity:0.9];
}

- (void)_dismissWithVelocity:(CGFloat)velocity
{
    [_dismissTimer invalidate];
    _dismissTimer = nil;
    
    self.toastControllerView.toastViewOffsetY = LIFEToastControllerViewDismissedOffsetY;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:velocity options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.dismissHandler();
    }];
}

@end
