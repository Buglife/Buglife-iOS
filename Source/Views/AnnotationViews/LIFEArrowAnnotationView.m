//
//  LIFEArrowAnnotationView.m
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

#import "LIFEArrowAnnotationView.h"
#import "UIColor+LIFEAdditions.h"
#import "UIBezierPath+LIFEAdditions.h"
#import "LIFEMacros.h"
#import "LIFEAnnotation.h"

@interface LIFEArrowAnnotationView ()
{
    CGFloat _arrowLength;
    LIFEArrowAnnotationLayer *_arrowAnnotationLayer;
}

@property (nonatomic) UIBezierPath *arrowPath;

@end

@implementation LIFEArrowAnnotationView

#pragma mark - UIView

- (id)init
{
    self = [super init];
    if (self) {
        self.opaque = NO;
//        self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//        self.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.layer.shadowOpacity = 1.0f;
//        self.layer.shadowRadius = 4.0f;
        
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = LIFELocalizedString(LIFEStringKey_Arrow);
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self.arrowPath containsPoint:point]) return self;
    CGRect boundingBox = _arrowPath.bounds;
    if ( (boundingBox.size.width < 80 || boundingBox.size.height < 80) &&
        CGRectContainsPoint(boundingBox, point)
        ) return self;
    
    return nil;
}

#pragma mark - Accessors

- (UIBezierPath *)arrowPath
{
    if (_arrowPath == nil) {
        [self _updateArrowPath];
    }
    
    return _arrowPath;
}

- (LIFEAnnotationLayer *)annotationLayer
{
    if (_arrowAnnotationLayer == nil) {
        _arrowAnnotationLayer = [LIFEArrowAnnotationLayer layer];
    }

    return _arrowAnnotationLayer;
}

- (void)setAnnotation:(LIFEAnnotation *)annotation
{
    [super setAnnotation:annotation];
    
    [self _updateArrowPath];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    [CATransaction setDisableActions:YES];
    [_arrowAnnotationLayer setNeedsDisplay];
    [CATransaction commit];
    
    self.accessibilityPath = _arrowPath;
    self.accessibilityValue = [NSString stringWithFormat:LIFELocalizedString(LIFEStringKey_ArrowAccessibilityValue), self.endPoint.y, self.endPoint.x];
}

- (UIBezierPath *)pathForPopoverMenu
{
    return _arrowPath;
}

- (void)_updateArrowPath
{
    _arrowLength = LIFECGPointDistance(self.startPoint, self.endPoint);
    _arrowPath = [LIFEUIBezierPath life_bezierPathWithArrowFromPoint:self.startPoint toPoint:self.endPoint];
}

@end





@implementation LIFEArrowAnnotationLayer

- (void)display
{
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self drawForFlattenedImageInContext:context];
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.contents = (id)result.CGImage;
    [CATransaction commit];

    UIGraphicsEndImageContext();
}

- (void)drawForFlattenedImageInContext:(CGContextRef)context
{
    CGPoint startPoint = self.startPoint;
    CGPoint endPoint = self.endPoint;
    
    UIColor *fillColor = [UIColor life_annotationFillColor];
    UIColor *strokeColor = [UIColor life_annotationStrokeColor];
    
    CGFloat arrowLength = LIFECGPointDistance(startPoint, endPoint);
    CGFloat tailWidth = LIFETailWidthForArrowLength(arrowLength);
    CGFloat strokeWidth = MAX(1.0f, tailWidth * 0.25f);

    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowOffset = CGSizeMake(0.1, -0.1);
    shadow.shadowBlurRadius = 8;
    
    UIBezierPath *arrowPath = [LIFEUIBezierPath life_bezierPathWithArrowFromPoint:startPoint toPoint:endPoint];
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    
    // stroke before fill, so the shadow is rendered around the stokre
    [strokeColor setStroke];
    arrowPath.lineWidth = strokeWidth;
    [arrowPath stroke];
    
    CGContextRestoreGState(context);
    
    // then fill
    [fillColor setFill];
    [arrowPath fill];
    
    // stroke again
    [strokeColor setStroke];
    arrowPath.lineWidth = strokeWidth;
    [arrowPath stroke];
}

@end
