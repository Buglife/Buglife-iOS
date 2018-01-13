//
//  LIFEAnnotationView.m
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

#import "LIFEAnnotationView.h"
#import "LIFEAnnotation.h"
#import "LIFEGeometry.h"
#import "UIColor+LIFEAdditions.h"

@interface LIFEAnnotationView ()

@property (nonatomic, getter=isAnimatingToTrashCan) BOOL animatingToTrashCan;

@end

@implementation LIFEAnnotationView

@dynamic startPoint;
@dynamic endPoint;

#pragma mark - Initialization

- (instancetype)initWithAnnotation:(LIFEAnnotation *)annotation
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _annotation = annotation;
        _annotationFillColor = [UIColor life_annotationFillColor];
        _annotationStrokeColor = [UIColor life_annotationStrokeColor];
        
        [self.layer addSublayer:self.annotationLayer];
        self.annotationLayer.annotation = annotation;
    }
    return self;
}

#pragma mark - UIView

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    if (layer == self.layer && self.isAnimatingToTrashCan == NO) {
        self.annotationLayer.frame = layer.bounds;
    }
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.annotationLayer setNeedsDisplay];
}

#pragma mark - Accessors

- (void)setScaledSourceImage:(UIImage *)scaledSourceImage
{
    _scaledSourceImage = scaledSourceImage;
    self.annotationLayer.scaledSourceImage = scaledSourceImage;
    [self setNeedsDisplay];
}

- (CGPoint)startPoint
{
    return LIFEPointFromVectorAndSize(self.annotation.startVector, self.bounds.size);
}

- (CGPoint)endPoint
{
    return LIFEPointFromVectorAndSize(self.annotation.endVector, self.bounds.size);
}

#pragma mark - Annotation

- (void)setAnnotation:(LIFEAnnotation *)annotation
{
    _annotation = annotation;
    [self setNeedsDisplay];
    self.annotationLayer.annotation = annotation;
    [self.annotationLayer setNeedsDisplay];
}

- (CGRect)annotationRect
{
    CGFloat originX = MIN(self.startPoint.x, self.endPoint.x);
    CGFloat originY = MIN(self.startPoint.y, self.endPoint.y);
    CGFloat width = fabs(self.endPoint.x - self.startPoint.x);
    CGFloat height = fabs(self.endPoint.y - self.startPoint.y);
    return CGRectMake(originX, originY, width, height);
}

- (UIBezierPath *)pathForPopoverMenu
{
    // override in subclass
    CGRect rect = [self annotationRect];
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect))];
    [path closePath];
    
    return path;
}

- (void)animateToTrashCanRect:(CGRect)trashCanRect completion:(LIFEAnnotationViewTrashCompletion)completionHandler
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        completionHandler();
    }];
    
    self.animatingToTrashCan = YES;
    
    CGRect oldFrame = self.annotationLayer.frame;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frame"];
    animation.duration = 0.25;
    animation.fromValue = [NSValue valueWithCGRect:oldFrame];
    animation.toValue = [NSValue valueWithCGRect:trashCanRect];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.annotationLayer addAnimation:animation forKey:@"frameAnimation"];
    self.annotationLayer.frame = trashCanRect;
    
    [CATransaction commit];
}

- (LIFEAnnotationLayer *)annotationLayer
{
    // implement in subclass
    NSParameterAssert(NO);
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // override in subclasses
}

@end





@implementation LIFEAnnotationLayer

//@dynamic startPoint;
//@dynamic endPoint;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setNeedsDisplay];
    }
    return self;
}

- (id)initWithLayer:(id)layer {
    if (self = [super initWithLayer:layer]) {
        if ([layer isKindOfClass:[LIFEAnnotationLayer class]]) {
            LIFEAnnotationLayer *other = (LIFEAnnotationLayer *)layer;
            self.annotation = other.annotation;
        }
    }
    
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    NSArray<NSString *> *keys = @[NSStringFromSelector(@selector(startPoint)),
                                  NSStringFromSelector(@selector(endPoint))];

    if ([keys containsObject:key]) {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (CGRect)annotationRect
{
    CGPoint startPoint = self.startPoint;
    CGFloat originX = MIN(startPoint.x, self.endPoint.x);
    CGFloat originY = MIN(self.startPoint.y, self.endPoint.y);
    CGFloat width = fabs(self.endPoint.x - self.startPoint.x);
    CGFloat height = fabs(self.endPoint.y - self.startPoint.y);
    return CGRectMake(originX, originY, width, height);
}

- (void)drawForFlattenedImageInContext:(CGContextRef)context
{
    NSAssert(NO, @"Subclasses must implement this!");
}

#pragma mark - Accessors

- (CGVector)startVector
{
    return self.annotation.startVector;
}

- (CGVector)endVector
{
    return self.annotation.endVector;
}

- (CGPoint)startPoint
{
    return LIFEPointFromVectorAndSize(self.startVector, self.bounds.size);
}

- (CGPoint)endPoint
{
    return LIFEPointFromVectorAndSize(self.endVector, self.bounds.size);
}

@end
