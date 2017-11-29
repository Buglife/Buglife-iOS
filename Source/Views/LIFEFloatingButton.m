//
//  LIFEFloatingButton.m
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
//

#import "LIFEFloatingButton.h"
#import "LIFEUserDefaults.h"
#import "UIBezierPath+LIFEAdditions.h"
#import "LIFEMacros.h"

static const CGSize kIntrinsicButtonSize = { 22, 22 };

@interface LIFEFloatingButton ()

@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint normalizedCenter;

// For some reason when we apply a rotation transform directly to the button,
// it breaks tap events. So I moved the dragonfly into a separate imageView,
// and just rotate that instead of rotating the entire button.
@property (nonatomic) UIImageView *dragonflyImageView;

@end

@implementation LIFEFloatingButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureRecognized:)];
        [self addGestureRecognizer:_panGestureRecognizer];

        UIImage *dragonflyImage = [[self class] _dragonflyImageWithColor:_foregroundColor];
        _dragonflyImageView = [[UIImageView alloc] initWithImage:dragonflyImage];
        _dragonflyImageView.contentMode = UIViewContentModeCenter;
        _dragonflyImageView.frame = self.bounds;
        _dragonflyImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_dragonflyImageView];
        
        [self sizeToFit];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        self.accessibilityLabel = LIFELocalizedString(LIFEStringKey_ReportABug);
        
        self.foregroundColor = nil; // Reset to default
        self.backgroundColor = nil; // Reset to default
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

#pragma mark - Accessors

- (void)setForegroundColor:(UIColor *)foregroundColor
{
    _foregroundColor = foregroundColor;
    
    if (_foregroundColor == nil) {
        _foregroundColor = [[self class] _defaultForegroundColor];
    }
    
    _dragonflyImageView.image = [[self class] _dragonflyImageWithColor:_foregroundColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    
    if (_backgroundColor == nil) {
        _backgroundColor = [[self class] _defaultBackgroundColor];
    }
    
    [self setNeedsDisplay];
}

#pragma mark - UIView

- (void)setCenter:(CGPoint)center
{
    center = [self _centerPointedConstrained:center];

    [super setCenter:center];
    
    if (self.superview != nil) {
        _normalizedCenter.x = center.x / self.superview.bounds.size.width;
        _normalizedCenter.y = center.y / self.superview.bounds.size.height;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return kIntrinsicButtonSize;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [self.backgroundColor setFill];
    [circlePath fill];
}

+ (UIImage *)_dragonflyImageWithColor:(UIColor *)color
{
    CGSize size = [LIFEUIBezierPath life_dragonFlyBezierPathSize];
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *dragonflyPath = [LIFEUIBezierPath life_dragonFlyBezierPath];
    
    [dragonflyPath applyTransform:CGAffineTransformMakeScale(0.5, 0.5)];
    [dragonflyPath applyTransform:CGAffineTransformMakeTranslation(7, 6.5)];
    
    [color setFill];
    [dragonflyPath fill];

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

#pragma mark - Private methods

+ (nonnull UIColor *)_defaultForegroundColor
{
    return [UIColor whiteColor];
}

+ (nonnull UIColor *)_defaultBackgroundColor
{
    return [UIColor blackColor];
}

- (void)_panGestureRecognized:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateChanged: {
            CGPoint newPosition = [panGestureRecognizer locationInView:self.superview];
            newPosition = [self _centerPointedConstrained:newPosition];
            self.center = newPosition;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [[LIFEUserDefaults sharedDefaults] setLastFloatingButtonCenterPoint:self.center];
            break;
        }
        default:
            break;
    }
}

- (void)_orientationDidChange:(NSNotification *)notification
{
    if (self.superview == nil) {
        return;
    }
    
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle = LIFEUIInterfaceOrientationAngleOfOrientation(statusBarOrientation);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    
    [UIView animateWithDuration:0 delay:0 options:options animations:^{
        self.dragonflyImageView.transform = transform;
    } completion:NULL];
}

- (CGPoint)_centerPointedConstrained:(CGPoint)centerPoint
{
    CGRect bounds = self.superview.bounds;
    
    if (centerPoint.x < CGRectGetMinX(bounds)) {
        centerPoint.x = CGRectGetMinX(bounds);
    } else if (centerPoint.x > CGRectGetMaxX(bounds)) {
        centerPoint.x = CGRectGetMaxX(bounds);
    }
    
    if (centerPoint.y < CGRectGetMinY(bounds)) {
        centerPoint.y = CGRectGetMinY(bounds);
    } else if (centerPoint.y > CGRectGetMaxY(bounds)) {
        centerPoint.y = CGRectGetMaxY(bounds);
    }
    
    return centerPoint;
}

static CGFloat LIFEUIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation)
{
    CGFloat angle;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    
    return angle;
}

@end
