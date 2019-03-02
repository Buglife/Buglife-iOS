//
//  LIFEImageEditorView.m
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

#import "LIFEImageEditorView.h"
#import "UIView+LIFEAdditions.h"
#import "LIFEScreenshotAnnotatorView.h"
#import "LIFELocalizedStringProvider.h"
#import "LIFEToolButton.h"
#import "UIImage+LIFEAdditions.h"
#import "NSArray+LIFEAdditions.h"
#import "UIImage+LIFEAdditions.h"
#import "LIFEAnnotatedImage.h"
#import "LIFEMacros.h"
#import "LIFEAppearanceImpl.h"
#import "UIColor+LIFEAdditions.h"
#import "LIFEImageEditorSegmentedControl.h"

let kImageBorderWidth = 2.0f;
let kNavBarButtonFontSize = 18.0f;
let kSegmentedControlHeight = 50.0f;
let kNavButtonTopConstraintConstant = 26.0f;

@interface LIFEImageEditorView ()

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIView *imageBorderView;
@property (nonatomic) LIFEImageEditorSegmentedControl *segmentedControl;
@property (nonatomic) LIFEScreenshotAnnotatorView *screenshotAnnotatorView;
@property (nonatomic) NSLayoutConstraint *segmentedControlBottomConstraint;

@end

@implementation LIFEImageEditorView

@dynamic toolDidChangeHandler;

- (instancetype)initWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage
{
    self = [super init];
    if (self) {
        id<LIFEAppearance> appearance = [LIFEAppearanceImpl sharedAppearance];
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = appearance.barTintColor;
        
        _imageBorderView = [[UIView alloc] init];
        _imageBorderView.backgroundColor = [[self class] imageBorderColor];
        
        _screenshotAnnotatorView = [[LIFEScreenshotAnnotatorView alloc] initWithAnnotatedImage:annotatedImage];
        [_screenshotAnnotatorView setToolbarsHidden:YES animated:NO completion:nil];
        
        NSArray *customViews = @[_backgroundView, _imageBorderView, _screenshotAnnotatorView];
        
        for (UIView *view in customViews) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [_backgroundView life_makeEdgesEqualTo:self];
        
        // Image constraints
        
        // On iPhone 7 Plus, the image is 1545px high (out of 2208px high screen, in portrait mode)
//        CGFloat multiplier = (1545.0f / 2208.0f);
        CGFloat aspectRatio = [LIFEUIImage life_aspectRatio:annotatedImage.sourceImage];
        
        [NSLayoutConstraint activateConstraints:@[
            [_screenshotAnnotatorView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kImageBorderWidth],
            [_screenshotAnnotatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_screenshotAnnotatorView.widthAnchor constraintEqualToAnchor:_screenshotAnnotatorView.heightAnchor multiplier:aspectRatio]
            ]];
        
        // Make the image border view just a bit bigger than the image
        
        [_imageBorderView life_makeEdgesEqualTo:_screenshotAnnotatorView withInset:-kImageBorderWidth];
        
        
        _segmentedControl = [[LIFEImageEditorSegmentedControl alloc] init];
        _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_segmentedControl];
        
        _segmentedControlBottomConstraint = [_segmentedControl.bottomAnchor constraintEqualToAnchor:self.life_safeAreaLayoutGuideBottomAnchor];
        
        [NSLayoutConstraint activateConstraints:@[
            [_screenshotAnnotatorView.bottomAnchor constraintEqualToAnchor:_segmentedControl.topAnchor],
            [_segmentedControl.heightAnchor constraintEqualToConstant:kSegmentedControlHeight],
            [_segmentedControl.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.75],
            [_segmentedControl.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            _segmentedControlBottomConstraint
            ]];
    }
    return self;
}

- (nonnull UIImageView *)sourceImageView
{
    return _screenshotAnnotatorView.sourceImageView;
}

- (LIFEToolButtonType)selectedTool
{
    return self.segmentedControl.selectedTool;
}

- (LIFEImageEditorSegmentedControlDidChange)toolDidChangeHandler
{
    return self.segmentedControl.didChangeHandler;
}

- (void)setToolDidChangeHandler:(LIFEImageEditorSegmentedControlDidChange)toolDidChangeHandler
{
    self.segmentedControl.didChangeHandler = toolDidChangeHandler;
}

#pragma mark - Transitions

- (void)prepareFirstPresentationTransition
{
    self.backgroundView.alpha = 0;
    self.screenshotAnnotatorView.alpha = 0;
    self.imageBorderView.hidden = YES;
    _segmentedControlBottomConstraint.constant = kSegmentedControlHeight;
    [self layoutIfNeeded];
}

- (void)prepareSecondPresentationTransition
{
    _segmentedControlBottomConstraint.constant = 0;
}

- (void)performSecondPresentationTransition
{
    [self layoutIfNeeded];
}

- (void)completeFirstPresentationTransition
{
    self.backgroundView.alpha = 1;
    self.screenshotAnnotatorView.alpha = 1;
    self.imageBorderView.hidden = NO;
}

+ (CGFloat)imageBorderWidth
{
    return kImageBorderWidth;
}

+ (nonnull UIColor *)imageBorderColor
{
    return [UIColor blackColor];
}

@end
