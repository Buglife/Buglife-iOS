//
//  UIContinuousForceTouchGestureRecognizer.h
//  Copyright (C) 2019 Buglife, Inc.
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

#import "LIFEFreeformGestureRecognizer.h"

static const CGPoint kFreeformGestureRecognizerStartPointEmpty = {0,0};

@interface LIFEFreeformGestureRecognizer ()

@property (nonatomic) CGPoint startPoint;

@end

@implementation LIFEFreeformGestureRecognizer

#pragma mark - UIGestureRecognizer overrides

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    _startPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (CGPointEqualToPoint(_startPoint, kFreeformGestureRecognizerStartPointEmpty)) {
        // This shouldn't happen, but if we're in a state that touches moved
        // but _startPoint is empty, then fail
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if ([self _didTouchesMoveSignificantly:touches]) {
        if (self.state == UIGestureRecognizerStatePossible) {
            self.state = UIGestureRecognizerStateBegan;
        } else if (self.state == UIGestureRecognizerStateBegan) {
            self.state = UIGestureRecognizerStateChanged;
        }
    }
}

- (void)_timerFired:(NSTimer *)timer
{
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self _didTouchesMoveSignificantly:touches]) {
        self.state = UIGestureRecognizerStateEnded;
    } else {
        // If touches ended but the user didn't drag their finger significantly,
        // then this was probably a tap or something else and should be
        // marked as a failure
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateCancelled;
}

- (BOOL)_didTouchesMoveSignificantly:(NSSet<UITouch *> *)touches
{
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:self.view];
    CGFloat x = fabs(location.x - _startPoint.x);
    CGFloat y = fabs(location.y - _startPoint.y);
    return (x > 3 || y > 3);
}

- (void)reset
{
    _startPoint = kFreeformGestureRecognizerStartPointEmpty;
}

@end
