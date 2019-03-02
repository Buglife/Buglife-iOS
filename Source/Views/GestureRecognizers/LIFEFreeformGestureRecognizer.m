//
//  LIFEFreeformGestureRecognizer.m
//  Buglife
//
//  Created by David Schukin on 3/1/19.
//

#import "LIFEFreeformGestureRecognizer.h"

@interface LIFEFreeformGestureRecognizer ()

@property (nonatomic, nullable) NSTimer *timer;

@end

@implementation LIFEFreeformGestureRecognizer

#pragma mark - UIGestureRecognizer overrides

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_timerFired:) userInfo:nil repeats:NO];
}

- (void)_timerFired:(NSTimer *)timer
{
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)reset
{
    [_timer invalidate];
    _timer = nil;
    [super reset];
}

@end
