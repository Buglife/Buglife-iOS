//
//  LIFEBlurAnnotationView.m
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

#import "LIFEBlurAnnotationView.h"
#import "UIImage+LIFEAdditions.h"
#import "UIColor+LIFEAdditions.h"
#import "LIFEMacros.h"

@interface LIFEBlurAnnotationLayer ()

@property (nonatomic) CGFloat borderAlpha;

@end

@interface LIFEBlurAnnotationView ()
{
    LIFEBlurAnnotationLayer *_blurAnnotationLayer;
}

@end

@implementation LIFEBlurAnnotationView

#pragma mark - Public methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSParameterAssert(_blurAnnotationLayer);
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = LIFELocalizedString(LIFEStringKey_Blur);
    }
    return self;
}

- (LIFEAnnotationLayer *)annotationLayer
{
    if (_blurAnnotationLayer == nil) {
        _blurAnnotationLayer = [LIFEBlurAnnotationLayer layer];
    }
    
    return _blurAnnotationLayer;
}

- (void)setAnnotation:(LIFEAnnotation *)annotation
{
    [super setAnnotation:annotation];
    
    CGRect annotationRect = [self annotationRect];
    self.accessibilityPath = [UIBezierPath bezierPathWithRect:annotationRect];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [CATransaction begin];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderAlpha"];
    animation.duration = 0.25;
    animation.fromValue = @((selected ? 0 : 1));
    animation.toValue = @((selected ? 1 : 0));
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    
    [_blurAnnotationLayer addAnimation:animation forKey:@"borderAlpha"];
    _blurAnnotationLayer.borderAlpha = (selected ? 1 : 0);
    
    [CATransaction commit];
}

@end



@implementation LIFEBlurAnnotationLayer

@dynamic borderAlpha;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([@"borderAlpha" isEqualToString:key]) {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (void)display
{
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    [self _drawWithBorderVisible:YES];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.contents = (id)result.CGImage;
    [CATransaction commit];
    UIGraphicsEndImageContext();
}

- (void)drawForFlattenedImageInContext:(CGContextRef)context
{
    [self _drawWithBorderVisible:NO];
}

- (void)_drawWithBorderVisible:(BOOL)borderVisible
{
    CGRect cropRect = [self annotationRect];

    {
        UIImage *blurredImage = self.scaledSourceImage;
        
        if (blurredImage) {
            UIImage *croppedBlurImage = [LIFEUIImage image:blurredImage croppedToRect:cropRect];
            [croppedBlurImage drawInRect:cropRect];
        }
    }
    
    if (borderVisible) {
        UIColor *borderColor = [UIColor life_annotationFillColor];
        borderColor = [borderColor colorWithAlphaComponent:(self.borderAlpha * 0.5)];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:cropRect];
        path.lineWidth = 1;
        [[UIColor clearColor] setFill];
        [borderColor setStroke];
        [path stroke];
    }
}

@end
