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

let kImageBorderWidth = 1.0f;
let kNavBarButtonFontSize = 18.0f;
let kToolbarHeight = 50.0f;
let kNavButtonTopConstraintConstant = 26.0f;

@interface LIFEImageEditorView ()

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *nextButton;
@property (nonatomic) UIView *imageBorderView;
@property (nonatomic) LIFEScreenshotAnnotatorView *screenshotAnnotatorView;
@property (nonatomic) NSLayoutConstraint *toolbarBottomConstraint;
@property (nonatomic) NSLayoutConstraint *cancelButtonTopConstraint;
@property (nonatomic) NSLayoutConstraint *nextButtonTopConstraint;

@end

@implementation LIFEImageEditorView

- (instancetype)initWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage
{
    self = [super init];
    if (self) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        
        UIColor *tintColor = [[self class] _buttonTintColor];
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:LIFELocalizedString(LIFEStringKey_Cancel) forState:UIControlStateNormal];
        UIFont *cancelbuttonFont = _cancelButton.titleLabel.font;
        cancelbuttonFont = [cancelbuttonFont fontWithSize:kNavBarButtonFontSize];
        _cancelButton.titleLabel.font = cancelbuttonFont;
        _cancelButton.tintColor = tintColor;
        
        _nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_nextButton setTitle:LIFELocalizedString(LIFEStringKey_Next) forState:UIControlStateNormal];
        UIFontDescriptor *nextButtonFontDescriptor = [[cancelbuttonFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        UIFont *nextButtonFont = [UIFont fontWithDescriptor:nextButtonFontDescriptor size:kNavBarButtonFontSize];
        _nextButton.titleLabel.font = nextButtonFont;
        _nextButton.tintColor = tintColor;
        
        _imageBorderView = [[UIView alloc] init];
        _imageBorderView.backgroundColor = [UIColor blackColor];
        
        _screenshotAnnotatorView = [[LIFEScreenshotAnnotatorView alloc] initWithAnnotatedImage:annotatedImage];
        [_screenshotAnnotatorView setToolbarsHidden:YES animated:NO completion:nil];
        
        NSArray *customViews = @[_backgroundView, _cancelButton, _nextButton, _imageBorderView, _screenshotAnnotatorView];
        
        for (UIView *view in customViews) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [_backgroundView life_makeEdgesEqualTo:self];
        
        // Top button constraints
        
        _cancelButtonTopConstraint = [_cancelButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:kNavButtonTopConstraintConstant];
        _nextButtonTopConstraint = [_nextButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:kNavButtonTopConstraintConstant];
        
        [NSLayoutConstraint activateConstraints:@[
                                                  [_cancelButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
                                                  _cancelButtonTopConstraint,
                                                  [_nextButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
                                                  _nextButtonTopConstraint
                                                  ]];
        
        // Image constraints
        
        // On iPhone 7 Plus, the image is 1545px high (out of 2208px high screen, in portrait mode)
//        CGFloat multiplier = (1545.0f / 2208.0f);
        CGFloat aspectRatio = [LIFEUIImage life_aspectRatio:annotatedImage.sourceImage];
        CGFloat navbarHeight = 44;
        CGFloat statusBarHeight = 20;
        CGFloat arbitraryMargin = 10;
        CGFloat verticalMargin = (kToolbarHeight + navbarHeight + statusBarHeight + arbitraryMargin); // Toolbar + nav + status bar
        
        [NSLayoutConstraint activateConstraints:@[
            [_screenshotAnnotatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_screenshotAnnotatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:(statusBarHeight / 2.0f)],
            [_screenshotAnnotatorView.widthAnchor constraintEqualToAnchor:_screenshotAnnotatorView.heightAnchor multiplier:aspectRatio],
            [_screenshotAnnotatorView.heightAnchor constraintEqualToAnchor:self.heightAnchor constant:-verticalMargin]
            ]];
        
        // Make the image border view just a bit bigger than the image
        
        [_imageBorderView life_makeEdgesEqualTo:_screenshotAnnotatorView withInset:-kImageBorderWidth];
        
        
        // TODO: Localize these strings!
        LIFEToolButton *arrowButton = [[LIFEToolButton alloc] init];
        arrowButton.imageView.image = [LIFEUIImage life_arrowToolbarIcon];
        arrowButton.titleView.text = @"Point";
        
        arrowButton.selected = YES;
        
        LIFEToolButton *loupeButton = [[LIFEToolButton alloc] init];
        loupeButton.imageView.image = [LIFEUIImage life_loupeIcon];
        loupeButton.titleView.text = @"Zoom";
        
        LIFEToolButton *blurButton = [[LIFEToolButton alloc] init];
        blurButton.imageView.image = [LIFEUIImage life_pixelateIcon];
        blurButton.titleView.text = @"Blur";
        
        NSArray *buttons = @[arrowButton, loupeButton, blurButton];
        
        for (LIFEToolButton *button in buttons) {
            UIColor *normalColor = [UIColor blackColor];
            [button setTintColor:normalColor forState:UIControlStateNormal];
            [button setTintColor:tintColor forState:UIControlStateSelected];
        }
        
        UIStackView *toolButtons = [[UIStackView alloc] initWithArrangedSubviews:@[arrowButton, loupeButton, blurButton]];
        toolButtons.axis = UILayoutConstraintAxisHorizontal;
        toolButtons.distribution = UIStackViewDistributionFillEqually;
        toolButtons.alignment = UIStackViewAlignmentFill;
        
        toolButtons.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:toolButtons];
        
        _toolbarBottomConstraint = [toolButtons.bottomAnchor constraintEqualToAnchor:self.bottomAnchor];
        
        [NSLayoutConstraint activateConstraints:@[
            [toolButtons.heightAnchor constraintEqualToConstant:kToolbarHeight],
            [toolButtons.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.75],
            [toolButtons.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            _toolbarBottomConstraint
            ]];
    }
    return self;
}

- (nonnull UIImageView *)sourceImageView
{
    return _screenshotAnnotatorView.sourceImageView;
}

#pragma mark - Transitions

- (void)prepareFirstPresentationTransition
{
    self.backgroundView.alpha = 0;
    self.imageBorderView.alpha = 0;
    self.screenshotAnnotatorView.alpha = 0;
    _toolbarBottomConstraint.constant = kToolbarHeight;
    _nextButtonTopConstraint.constant = -kNavButtonTopConstraintConstant;
    _cancelButtonTopConstraint.constant = -kNavButtonTopConstraintConstant;
    [self layoutIfNeeded];
}

- (void)prepareSecondPresentationTransition
{
    _toolbarBottomConstraint.constant = 0;
    _nextButtonTopConstraint.constant = kNavButtonTopConstraintConstant;
    _cancelButtonTopConstraint.constant = kNavButtonTopConstraintConstant;
}

- (void)performSecondPresentationTransition
{
    [self layoutIfNeeded];
}

- (void)completeFirstPresentationTransition
{
    self.backgroundView.alpha = 1;
    self.screenshotAnnotatorView.alpha = 1;
    self.imageBorderView.alpha = 1;
}

#pragma mark - Private methods

+ (nonnull UIColor *)_buttonTintColor
{
    return [UIColor blueColor];
}

@end
