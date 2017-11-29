//
//  LIFELoupeAnnotationView.m
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

#import "LIFELoupeAnnotationView.h"
#import "UIImage+LIFEAdditions.h"
#import "LIFEMacros.h"

static const CGFloat kZoomFactor = 2.0;

@implementation LIFELoupeAnnotationView
{
    LIFELoupeAnnotationLayer *_loupeAnnotationLayer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = LIFELocalizedString(LIFEStringKey_LoupeAccessibilityLabel);
    }
    return self;
}

- (LIFEAnnotationLayer *)annotationLayer
{
    if (_loupeAnnotationLayer == nil) {
        _loupeAnnotationLayer = [LIFELoupeAnnotationLayer layer];
    }
    
    return _loupeAnnotationLayer;
}

- (void)setAnnotation:(LIFEAnnotation *)annotation
{
    [super setAnnotation:annotation];
    
    CGRect annotationRect = [self annotationRect];
    self.accessibilityPath = [UIBezierPath bezierPathWithOvalInRect:annotationRect];
    self.accessibilityValue = [NSString stringWithFormat:LIFELocalizedString(LIFEStringKey_LoupeAccessibilityValue), CGRectGetMidX(annotationRect), CGRectGetMidY(annotationRect), CGRectGetWidth(annotationRect), CGRectGetHeight(annotationRect)];
}

#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect cropRect = [self annotationRect];
    
    if (CGRectContainsPoint(cropRect, point)) {
        return self;
    }
    
    return nil;
}

#pragma mark - SNRAnnotationView

- (CGRect)annotationRect
{
    return _loupeAnnotationLayer.annotationRect;
}

@end



@implementation LIFELoupeAnnotationLayer

- (void)display
{
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    {
        [self drawForFlattenedImageInContext:nil];
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.contents = (id)result.CGImage;
    [CATransaction commit];

    UIGraphicsEndImageContext();
}

- (CGRect)annotationRect
{
    CGFloat xDist = (self.endPoint.x - self.startPoint.x);
    CGFloat yDist = (self.endPoint.y - self.startPoint.y);
    CGFloat radius = sqrt((xDist * xDist) + (yDist * yDist));
    CGFloat x = self.startPoint.x - radius;
    CGFloat y = self.startPoint.y - radius;
    return CGRectMake(x, y, (radius * 2), (radius * 2));
}

- (void)drawForFlattenedImageInContext:(CGContextRef)context
{
    CGRect cropRect = [self annotationRect];
    UIImage *scaledSourceImage = self.scaledSourceImage;
    UIBezierPath *circularPath = [UIBezierPath bezierPathWithOvalInRect:cropRect];
    
    [UIColor.blackColor setStroke];
    circularPath.lineWidth = 1;
    [circularPath stroke];
    
    [circularPath addClip]; // clip the image to the circular path
    
    CGFloat insetX = -(CGRectGetWidth(cropRect) / kZoomFactor);
    CGFloat insetY = -(CGRectGetHeight(cropRect) / kZoomFactor);
    CGRect zoomedRect = CGRectInset(cropRect, insetX, insetY);
    
    if (scaledSourceImage) {
        UIImage *croppedImage = [LIFEUIImage image:scaledSourceImage croppedToRect:cropRect];
        [croppedImage drawInRect:zoomedRect];
    }
}

@end
