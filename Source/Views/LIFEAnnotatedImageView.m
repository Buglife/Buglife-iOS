//
//  LIFEAnnotatedImageView.m
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

#import "LIFEAnnotatedImageView.h"
#import "LIFEArrowAnnotationView.h"
#import "LIFEBlurAnnotationView.h"
#import "LIFELoupeAnnotationView.h"
#import "LIFEAnnotatedImage.h"
#import "NSArray+LIFEAdditions.h"
#import "UIView+LIFEAdditions.h"
#import "UIImage+LIFEAdditions.h"
#import "LIFEMacros.h"

@interface LIFEAnnotatedImageView ()

@property (nonatomic) UIImageView *sourceImageView;
@property (nonatomic) NSString *sourceImageFilename;
@property (nonatomic) NSMutableArray<LIFEBlurAnnotationView *> *blurAnnotationViews;
@property (nonatomic) NSMutableArray<LIFELoupeAnnotationView *> *loupeAnnotationViews;
@property (nonatomic) NSMutableArray<LIFEArrowAnnotationView *> *arrowAnnotationViews;

@end

@implementation LIFEAnnotatedImageView

@dynamic annotationViews;

#pragma mark - Lifecycle

- (instancetype)initWithAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    self = [super init];
    if (self) {
        _sourceImageView = [[UIImageView alloc] initWithImage:annotatedImage.sourceImage];
        _sourceImageView.userInteractionEnabled = YES;
        _sourceImageView.isAccessibilityElement = YES;
        [self addSubview:_sourceImageView];
        
        _sourceImageFilename = annotatedImage.filename;
        
        _blurAnnotationViews = [annotatedImage.annotations life_arrayFilteredToObjectsOfClass:[LIFEBlurAnnotationView class]].mutableCopy;
        _loupeAnnotationViews = [annotatedImage.annotations life_arrayFilteredToObjectsOfClass:[LIFELoupeAnnotationView class]].mutableCopy;
        _arrowAnnotationViews = [annotatedImage.annotations life_arrayFilteredToObjectsOfClass:[LIFEArrowAnnotationView class]].mutableCopy;
        
        for (UIView *view in _blurAnnotationViews) {
            [self addSubview:view];
        }
        
        for (UIView *view in _loupeAnnotationViews) {
            [self addSubview:view];
        }
        
        for (UIView *view in _arrowAnnotationViews) {
            [self addSubview:view];
        }
        
        [self _reorderSubviews];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

#pragma mark - Layout

- (void)updateConstraints
{
    _sourceImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_sourceImageView life_makeEdgesEqualTo:self];
    
    // All arrow & blur annotation views are edge-to-edge
    for (LIFEAnnotationView *annotationView in [self _allAnnotationViews]) {
        annotationView.translatesAutoresizingMaskIntoConstraints = NO;
        [annotationView life_makeEdgesEqualTo:self];
    }
    
    [super updateConstraints];
}

- (void)_reorderSubviews
{
    for (LIFELoupeAnnotationView *loupe in _loupeAnnotationViews) {
        [self bringSubviewToFront:loupe];
    }
    
    for (LIFEArrowAnnotationView *arrow in _arrowAnnotationViews) {
        [self bringSubviewToFront:arrow];
    }
}

#pragma mark - Add / Remove annotations

- (void)_addArrowAnnotationView:(LIFEArrowAnnotationView *)arrowAnnotationView
{
    [_arrowAnnotationViews addObject:arrowAnnotationView];
    [self addSubview:arrowAnnotationView];
    [self _reorderSubviews];
    [self setNeedsUpdateConstraints];
}

- (void)_addLoupeAnnotationView:(LIFELoupeAnnotationView *)loupeAnnotationView
{
    [_loupeAnnotationViews addObject:loupeAnnotationView];
    [self addSubview:loupeAnnotationView];
    [self _reorderSubviews];
    [self setNeedsUpdateConstraints];
}

- (void)_addBlurAnnotationView:(LIFEBlurAnnotationView *)blurAnnotationView
{
    [_blurAnnotationViews addObject:blurAnnotationView];
    [self addSubview:blurAnnotationView];
    [self _reorderSubviews];
    [self setNeedsUpdateConstraints];
}

- (void)addAnnotationView:(LIFEAnnotationView *)annotationView
{
    if ([annotationView isKindOfClass:[LIFEArrowAnnotationView class]]) {
        [self _addArrowAnnotationView:(LIFEArrowAnnotationView *)annotationView];
    } else if ([annotationView isKindOfClass:[LIFELoupeAnnotationView class]]) {
        [self _addLoupeAnnotationView:(LIFELoupeAnnotationView *)annotationView];
    } else if ([annotationView isKindOfClass:[LIFEBlurAnnotationView class]]) {
        [self _addBlurAnnotationView:(LIFEBlurAnnotationView *)annotationView];
    } else {
        NSParameterAssert(NO); // not implemented
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)animateAddedAnnotationView:(LIFEAnnotationView *)annotationView
{
    CGPoint annotationCenterPoint = CGPointMake(annotationView.startPoint.x + (annotationView.endPoint.x - annotationView.startPoint.x) / 2.0,
                                                annotationView.startPoint.y + (annotationView.endPoint.y - annotationView.startPoint.y) / 2.0);
    
    CATransform3D initialTransform = CATransform3DIdentity;
    initialTransform = CATransform3DTranslate(initialTransform,
                                              (annotationCenterPoint.x - annotationView.center.x),
                                              (annotationCenterPoint.y - annotationView.center.y),
                                              0);
    initialTransform = CATransform3DScale(initialTransform, .05, .05, 1);
    initialTransform = CATransform3DTranslate(initialTransform,
                                              -(annotationCenterPoint.x - annotationView.center.x),
                                              -(annotationCenterPoint.y - annotationView.center.y),
                                              0);
    
    BOOL quartzSpringAnimationAvailable = [CASpringAnimation instancesRespondToSelector:@selector(setInitialVelocity:)];
    
    if (quartzSpringAnimationAvailable) {
        CASpringAnimation *animation = [CASpringAnimation animationWithKeyPath:@"sublayerTransform"];
        animation.fromValue = [NSValue valueWithCATransform3D:initialTransform];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation.damping = 10;
        animation.stiffness = 95;
        animation.initialVelocity = .5;
        animation.duration = animation.settlingDuration;
        [annotationView.layer addAnimation:animation forKey:@"sublayerTransform"];
    } else {
        [UIView performWithoutAnimation:^{
            annotationView.transform = CATransform3DGetAffineTransform(initialTransform);
        }];
        
        CATransform3D finalTransform = CATransform3DIdentity;
        [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            annotationView.transform = CATransform3DGetAffineTransform(finalTransform);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)removeAnnotationView:(LIFEAnnotationView *)annotationView
{
    if ([annotationView isKindOfClass:[LIFEArrowAnnotationView class]]) {
        [_arrowAnnotationViews removeObject:(LIFEArrowAnnotationView *)annotationView];
    } else if ([annotationView isKindOfClass:[LIFELoupeAnnotationView class]]) {
        [_loupeAnnotationViews removeObject:(LIFELoupeAnnotationView *)annotationView];
    } else if ([annotationView isKindOfClass:[LIFEBlurAnnotationView class]]) {
        [_blurAnnotationViews removeObject:(LIFEBlurAnnotationView *)annotationView];
    } else {
        NSParameterAssert(NO); // not implemented
    }
    
    [annotationView removeFromSuperview];
}

#pragma mark - Other public methods

- (NSArray<LIFEAnnotationView *> *)annotationViews
{
    return [self _allAnnotationViews];
}

- (void)updateLoupeAnnotationViewsWithSourceImage:(UIImage *)sourceImage
{
    for (LIFELoupeAnnotationView *loupeAnnotationView in _loupeAnnotationViews) {
        loupeAnnotationView.scaledSourceImage = sourceImage;
        [loupeAnnotationView setNeedsDisplay];
    }
}

- (CGFloat)aspectRatio
{
    return [LIFEUIImage life_aspectRatio:self.sourceImageView.image];
}

#pragma mark - Private methods

- (NSArray *)_allAnnotationViews
{
    NSMutableArray *annotationViews = [NSMutableArray array];
    [annotationViews addObjectsFromArray:_blurAnnotationViews];
    [annotationViews addObjectsFromArray:_loupeAnnotationViews];
    [annotationViews addObjectsFromArray:_arrowAnnotationViews];
    return [NSArray arrayWithArray:annotationViews];
}

@end
