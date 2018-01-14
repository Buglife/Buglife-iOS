//
//  LIFEJelloView.m
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
#import "LIFEJelloView.h"
#import "LIFEJelloLayer.h"
#import "LIFEMacros.h"

static let kSpringDamping = 0.7f;
static let kInitialSpringVelocity = 0.8f;

@interface LIFEJelloView () <LIFEJelloLayerDelegate>

@property (nonnull, nonatomic) UIView *dummyView;
@property (nonnull, nonatomic) CAShapeLayer *shapeLayer;
@property (nonatomic) UIOffset bendableOffset;
@property (nullable, nonatomic) CADisplayLink *displayLink;
@property (nonatomic) NSInteger animationCount;

@end

@implementation LIFEJelloView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _animationCount = 0;
        _bendableOffset = UIOffsetZero;
        _dummyView = [[UIView alloc] init];
        _shapeLayer = [CAShapeLayer layer];
        [self.layer insertSublayer:_shapeLayer atIndex:0];
        [self updatePath];
        _shapeLayer.fillColor = [[self class] backgroundColor].CGColor;
        
        [self addSubview:_dummyView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updatePath];
    
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth(_dummyView.frame), CGRectGetHeight(_dummyView.frame));
    _dummyView.frame = newFrame;
}

+ (Class)layerClass
{
    return [LIFEJelloLayer class];
}

+ (UIColor *)backgroundColor
{
    NSAssert(NO, @"Override this in a subclass!");
    return [UIColor redColor];
}

#pragma mark - Accessors

- (void)setBendableOffset:(UIOffset)bendableOffset
{
    _bendableOffset = bendableOffset;
    [self updatePath];
}

#pragma mark - LIFEJelloLayerDelegate

- (void)jelloLayer:(LIFEJelloLayer *)jelloLayer willStartAnimation:(CABasicAnimation *)animation
{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_tick:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    _animationCount += 1;
    
    let newOrigin = self.layer.frame.origin;
    let oldSize = self.dummyView.frame.size;
    let newFrame = CGRectMake(newOrigin.x, newOrigin.y, oldSize.width, oldSize.height);
    let options = (UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionOverrideInheritedOptions);
    
    [UIView animateWithDuration:animation.duration delay:animation.beginTime usingSpringWithDamping:kSpringDamping initialSpringVelocity:kInitialSpringVelocity options:options animations:^{
        self.dummyView.frame = newFrame;
    } completion:^(BOOL finished) {
        self.animationCount -= 1;
        
        if (self.animationCount == 0) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
    }];
}

#pragma mark - Private methods

- (void)updatePath
{
    CGRect bounds;
    CALayer *presentationLayer = self.layer.presentationLayer;
    
    if (presentationLayer) {
        bounds = presentationLayer.bounds;
    } else {
        bounds = self.bounds;
    }
    
    let width = CGRectGetWidth(bounds);
    let height = CGRectGetHeight(bounds);
    let path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointZero];
    [path addQuadCurveToPoint:CGPointMake(width, 0) controlPoint:CGPointMake(width / 2.0, _bendableOffset.vertical)];
    [path addQuadCurveToPoint:CGPointMake(width, height) controlPoint:CGPointMake(width + _bendableOffset.horizontal, height / 2.0)];
    [path addQuadCurveToPoint:CGPointMake(0, height) controlPoint:CGPointMake(width / 2.0, height + _bendableOffset.vertical)];
    [path addQuadCurveToPoint:CGPointZero controlPoint:CGPointMake(_bendableOffset.horizontal, height / 2.0)];
    [path closePath];
    
    _shapeLayer.path = path.CGPath;
}

- (void)_tick:(CADisplayLink *)displayLink
{
    CALayer *dummyViewPresentationLayer = _dummyView.layer.presentationLayer;
    
    if (dummyViewPresentationLayer) {
        CALayer *presentationLayer = self.layer.presentationLayer;
        
        if (presentationLayer) {
            let horizontal = CGRectGetMinX(dummyViewPresentationLayer.frame) - CGRectGetMinX(presentationLayer.frame);
            let vertical = CGRectGetMinY(dummyViewPresentationLayer.frame) - CGRectGetMinY(presentationLayer.frame);
            self.bendableOffset = UIOffsetMake(horizontal, vertical);
        }
    }
}

@end
