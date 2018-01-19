//
//  LIFEScreenshotAnnotatorView.m
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

#import "LIFEScreenshotAnnotatorView.h"
#import "LIFEAnnotatedImageView.h"
#import "LIFEArrowAnnotationView.h"
#import "LIFEBlurAnnotationView.h"
#import "LIFELoupeAnnotationView.h"
#import "UIImage+LIFEAdditions.h"
#import "LIFEAnnotatedImage.h"
#import "NSLayoutConstraint+LIFEAdditions.h"
#import "UIView+LIFEAdditions.h"
#import "UIColor+LIFEAdditions.h"
#import "LIFEAppearanceImpl.h"
#import "LIFECompatibilityUtils.h"
#import "LIFEMacros.h"

static const CGFloat kSegmentItemWidth = 100;
static const NSTimeInterval kToolbarTransitionDuration = 0.25;

@interface LIFEPassThroughTouchesView : UIView
@end

@interface LIFEScreenshotAnnotatorView ()

@property (nonatomic, nonnull) UIImageView *backgroundImageView;
@property (nonatomic, nonnull) UIVisualEffectView *backgroundBlurView;
@property (nonatomic, nonnull) LIFEAnnotatedImageView *annotatedImageView;

@property (nonatomic) UIView *segmentedControlToolbarContainer;
@property (nonatomic) UIToolbar *segmentedControlToolbar;
@property (nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic) NSLayoutConstraint *segmentedControlToolbarBottomConstraint;

@end

@implementation LIFEScreenshotAnnotatorView

@dynamic annotationViews;

#pragma mark - Lifecycle

- (instancetype)initWithAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    self = [super init];
    if (self) {
        self.tintColor = LIFEAppearanceImpl.sharedAppearance.tintColor;
        
        _backgroundImageView = [[UIImageView alloc] initWithImage:annotatedImage.sourceImage];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_backgroundImageView];
        _backgroundBlurView.clipsToBounds = YES;
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _backgroundBlurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [self addSubview:_backgroundBlurView];
        
        _annotatedImageView = [[LIFEAnnotatedImageView alloc] initWithAnnotatedImage:annotatedImage];
        [self addSubview:_annotatedImageView];
        
        _segmentedControlToolbarContainer = [[UIView alloc] init];
        _segmentedControlToolbarContainer.backgroundColor = LIFEAppearanceImpl.sharedAppearance.barTintColor;
        [self addSubview:_segmentedControlToolbarContainer];
        
        _segmentedControlToolbar = [[UIToolbar alloc] init];
        _segmentedControlToolbar.barTintColor = [UIColor clearColor];
        _segmentedControlToolbar.translucent = YES;
        [_segmentedControlToolbarContainer addSubview:_segmentedControlToolbar];
        
        UIImage *arrowIcon = [LIFEUIImage life_arrowToolbarIcon];
        UIImage *loupeIcon = [LIFEUIImage life_loupeIcon];
        UIImage *pixelateIcon = [LIFEUIImage life_pixelateIcon];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[arrowIcon, loupeIcon, pixelateIcon]];
        _segmentedControl.selectedSegmentIndex = LIFEAnnotationTypeArrow;
        [_segmentedControl setWidth:kSegmentItemWidth forSegmentAtIndex:0];
        [_segmentedControl setWidth:kSegmentItemWidth forSegmentAtIndex:1];
        [_segmentedControl setWidth:kSegmentItemWidth forSegmentAtIndex:2];
        [_segmentedControlToolbarContainer addSubview:_segmentedControl];
        
        NSArray *customSubviews = @[_backgroundImageView, _backgroundBlurView, _annotatedImageView, _segmentedControlToolbarContainer, _segmentedControlToolbar, _segmentedControl];
        
        for (UIView *view in customSubviews) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }

        [self life_configureConstraints];
        
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - Layout

- (void)life_configureConstraints
{
    [_backgroundImageView life_makeEdgesEqualTo:self];
    [_backgroundBlurView life_makeEdgesEqualTo:self];
    
    CGFloat aspectRatio = self.annotatedImageView.aspectRatio;
    
    NSLayoutConstraint *imageViewWidthConstraint = [_annotatedImageView.widthAnchor constraintEqualToAnchor:self.widthAnchor];
    NSLayoutConstraint *imageViewHeightConstraint = [_annotatedImageView.heightAnchor constraintEqualToAnchor:self.heightAnchor];
    imageViewWidthConstraint.priority = UILayoutPriorityDefaultHigh;
    imageViewHeightConstraint.priority = UILayoutPriorityDefaultHigh;
    
    [NSLayoutConstraint activateConstraints:@[
                                              [_annotatedImageView.widthAnchor constraintEqualToAnchor:_annotatedImageView.heightAnchor multiplier:aspectRatio],
                                              [_annotatedImageView.widthAnchor constraintLessThanOrEqualToAnchor:self.widthAnchor],
                                              [_annotatedImageView.heightAnchor constraintLessThanOrEqualToAnchor:self.heightAnchor],
                                              imageViewWidthConstraint,
                                              imageViewHeightConstraint,
                                              [_annotatedImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
                                              [_annotatedImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
                                              ]];
    
    if (_segmentedControlToolbarBottomConstraint == nil) {
        _segmentedControlToolbarBottomConstraint = [_segmentedControlToolbarContainer.bottomAnchor constraintEqualToAnchor:self.bottomAnchor];
    
        [NSLayoutConstraint activateConstraints:@[
                                                  [_segmentedControlToolbarContainer.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
                                                  [_segmentedControlToolbarContainer.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
                                                  _segmentedControlToolbarBottomConstraint
                                                  ]];
    }
    
    NSLayoutYAxisAnchor *segmentedControlContainerBottomConstraintAnchor = _segmentedControlToolbarContainer.life_safeAreaLayoutGuideBottomAnchor;
    
    [NSLayoutConstraint activateConstraints:@[
                                              // The toolbar has a width of 0, because we only use it as a placeholder to configure relative
                                              // auto layout constraints. We don't actually want it visible, because UIToolbar
                                              // has its own background visual effect view
                                              [_segmentedControlToolbar.widthAnchor constraintEqualToConstant:0],
                                              [_segmentedControlToolbar.leadingAnchor constraintEqualToAnchor:_segmentedControlToolbarContainer.leadingAnchor],
                                              [_segmentedControlToolbar.topAnchor constraintEqualToAnchor:_segmentedControlToolbarContainer.topAnchor],
                                              [_segmentedControlToolbar.bottomAnchor constraintEqualToAnchor:segmentedControlContainerBottomConstraintAnchor]
                                              ]];
    
    [NSLayoutConstraint activateConstraints:@[
                                              [_segmentedControl.centerXAnchor constraintEqualToAnchor:_segmentedControlToolbarContainer.centerXAnchor],
                                              [_segmentedControl.centerYAnchor constraintEqualToAnchor:_segmentedControlToolbar.centerYAnchor],
                                              [_segmentedControl.widthAnchor constraintEqualToConstant:300]
                                              ]];
    
    [super updateConstraints];
}

#pragma mark - Public methods

- (LIFEAnnotationType)selectedAnnotationType
{
    return _segmentedControl.selectedSegmentIndex;
}

- (void)setToolbarsHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(void))completion
{
    _toolbarsHidden = hidden;
    CGFloat offset = 0;
    
    if (hidden) {
        offset = [self _estimatedSegmentedControlToolbarContainerHeight];
    }
    
    _segmentedControlToolbarBottomConstraint.constant = offset;

    if (animated) {
        [UIView animateWithDuration:kToolbarTransitionDuration animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

- (CGFloat)_estimatedSegmentedControlToolbarContainerHeight
{
    CGFloat height = CGRectGetHeight(_segmentedControlToolbarContainer.frame);
    
    if (height < 1) {
        // Since this method can be called to hide the toolbar container before
        // the Auto Layout engine has actually had a chance to lay out its views,
        // we need to be able to estimate the height using (a) the toolbar within it,
        // (b) the non-safe area
        height = _segmentedControlToolbar.intrinsicContentSize.height;
        
        // This is a hack to account for the safe area; Since the safe area insets
        // aren't available until the view is visible on the screen, we need to
        // estimate them
        height *= 2;
    }
    
    return height;
}

- (UIImageView *)sourceImageView
{
    return self.annotatedImageView.sourceImageView;
}

- (NSArray<LIFEAnnotationView *> *)annotationViews
{
    return self.annotatedImageView.annotationViews;
}

- (void)addAnnotationView:(LIFEAnnotationView *)annotationView
{
    [self.annotatedImageView addAnnotationView:annotationView];
}

- (void)animateAddedAnnotationView:(LIFEAnnotationView *)annotationView
{
    [self.annotatedImageView animateAddedAnnotationView:annotationView];
}

- (void)removeAnnotationView:(LIFEAnnotationView *)annotationView
{
    [self.annotatedImageView removeAnnotationView:annotationView];
}

- (void)updateLoupeAnnotationViewsWithSourceImage:(UIImage *)sourceImage
{
    [self.annotatedImageView updateLoupeAnnotationViewsWithSourceImage:sourceImage];
}

+ (NSTimeInterval)toolbarTransitionDuration
{
    return kToolbarTransitionDuration;
}

#pragma mark - Private methods

@end



@implementation LIFEPassThroughTouchesView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

@end
