//
//  LIFEFreeformAnnotationView.m
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
//

#import "LIFEFreeformAnnotationView.h"
#import "LIFEAnnotation.h"

static const CGFloat kLIFEFreeformAnnotationLineWidth = 3.0;
static const CGFloat kLIFEFreeformAnnotationTouchWidth = 20.0;

@interface LIFEFreeformAnnotationLayer ()

- (UIBezierPath *)scaledBezierPath;

@end

@implementation LIFEFreeformAnnotationView
{
    LIFEFreeformAnnotationLayer *_freeformAnnotationLayer;
}

#pragma mark - Public methods

- (instancetype)initWithAnnotation:(LIFEAnnotation *)annotation
{
    self = [super initWithAnnotation:annotation];
    if (self) {
        NSParameterAssert(_freeformAnnotationLayer);
    }
    return self;
}

- (LIFEAnnotationLayer *)annotationLayer
{
    if (_freeformAnnotationLayer == nil) {
        _freeformAnnotationLayer = [LIFEFreeformAnnotationLayer layer];
    }
    
    return _freeformAnnotationLayer;
}

- (UIBezierPath *)scaledBezierPath
{
    LIFEFreeformAnnotationLayer *layer = (LIFEFreeformAnnotationLayer *)self.annotationLayer;
    return layer.scaledBezierPath;
}

- (BOOL)containsLocation:(CGPoint)location
{
    UIBezierPath *path = [self scaledBezierPath];
    
    // Expand the path, because it's way too hard to
    // accurately tap the drawing itself
    CGFloat width = kLIFEFreeformAnnotationTouchWidth;
    CGPathRef strokedPath = CGPathCreateCopyByStrokingPath(path.CGPath, NULL, width, kCGLineCapRound, kCGLineJoinRound, 0);
    UIBezierPath *expandedPath = [UIBezierPath bezierPathWithCGPath:strokedPath];
    CGPathRelease(strokedPath);
    
    if ([expandedPath containsPoint:location]) {
        return YES;
    } else {
        return NO;
    }
}

- (UIBezierPath *)pathForPopoverMenu
{
    return self.scaledBezierPath;
}

@end

@implementation LIFEFreeformAnnotationLayer

- (void)display
{
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    [self _drawStroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    self.contents = (id)result.CGImage;
    UIGraphicsEndImageContext();
}

- (void)drawForFlattenedImageInContext:(CGContextRef)context
{
    [self _drawStroke];
}

- (void)_drawStroke
{
    UIBezierPath *path = [self scaledBezierPath];
    path.lineWidth = kLIFEFreeformAnnotationLineWidth;
    [[UIColor redColor] setStroke];
    [path stroke];
}

- (UIBezierPath *)scaledBezierPath
{
    CGSize size = self.bounds.size;
    UIBezierPath *pathCopy = self.annotation.bezierPath.copy;
    CGAffineTransform transform = CGAffineTransformMakeScale(size.width, size.height);
    [pathCopy applyTransform:transform];
    return pathCopy;
}

@end
