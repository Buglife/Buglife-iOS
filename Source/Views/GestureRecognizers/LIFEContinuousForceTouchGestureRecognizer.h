//
//  UIContinuousForceTouchGestureRecognizer.h
//  Copyright (C) 2017 Buglife, Inc.
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

#import <UIKit/UIKit.h>

@class LIFEContinuousForceTouchGestureRecognizer;

@protocol LIFEContinuousForceTouchDelegate <NSObject>

// Force touch was recognized according to the thresholds set by baseForceTouchPressure, triggeringForceTouchPressure, and forceTouchDelay
- (void) forceTouchRecognized:(LIFEContinuousForceTouchGestureRecognizer *)recognizer;

@optional
// Force touch started happening. Note that this is not necessary the moment when all touches started happening, just the moment when the first touch occurred with at least a force of baseForceTouchPressure
- (void)forceTouchRecognizer:(LIFEContinuousForceTouchGestureRecognizer *)recognizer didStartWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;

// Force touch movement happening. This is only called if forceTouchDidStartWithForce had been called previously
- (void)forceTouchRecognizer:(LIFEContinuousForceTouchGestureRecognizer *)recognizer didMoveWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;

// Force touch was cancelled. This is only called if forceTouchDidStartWithForce had been called previously
- (void)forceTouchRecognizer:(LIFEContinuousForceTouchGestureRecognizer *)recognizer didCancelWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;

// Force touch ended. This is only called if forceTouchDidStartWithForce had been called previously
- (void)forceTouchRecognizer:(LIFEContinuousForceTouchGestureRecognizer *)recognizer didEndWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;

// Force touch timed out. See notes about the timeout property below. This is only called if forceTouchDidStartWithForce had been called previously
- (void) forceTouchDidTimeout:(LIFEContinuousForceTouchGestureRecognizer *)recognizer;


@end


@interface LIFEContinuousForceTouchGestureRecognizer : UIGestureRecognizer

// The lowest pressuare at which a force touch will begin to be detected,
//      anything lower is a normal press and will not trigger force touch logic
// Defaults to 1.0f on a scale from 0.0f to 6.667f;
@property(nonatomic, assign) CGFloat baseForceTouchPressure;

// The pressure at which a force touch will be triggered
// Defaults to 2.5f on a scale from 0.0f to 6.667f;
@property(nonatomic, assign) CGFloat triggeringForceTouchPressure;

// The delay in seconds after which, if the baseForceTouchPressure or greater is
//      still being applied will recognize the force touch
// Defaults to 0.5f (half a second)
@property(nonatomic, assign) CGFloat forceTouchDelay;

// The timeout in seconds after which will fail the gesture recognizer. It fires only if a touch event
//      is not received again after forceTouchDidStartWithForce or forceTouchDidMoveWithForce is called.
//
// When this occurs forceTouchDidTimeout is called and the state is set to UIGestureRecognizerStateFailed.
// Defaults to 1.5f;
//
// This comes in handy when you have a view inside a scroll view and the if the user drags to scroll the
//      view this gesture recognizer will not get its touchesCancelled or touchesEnded methods called
@property(nonatomic, assign) CGFloat timeout;

// Set this delegate to get continuous feedback on pressure changes
@property(nonatomic, weak) id<LIFEContinuousForceTouchDelegate> forceTouchDelegate;


@end
