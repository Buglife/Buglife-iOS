//
//  LIFEImageEditorView.m
//  Buglife
//
//  Created by David Schukin on 12/28/17.
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

let kImageBorderWidth = 2.0f;
let kNavBarButtonFontSize = 18.0f;

@interface LIFEImageEditorView ()

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *nextButton;
@property (nonatomic) UIView *imageBorderView;
@property (nonatomic) LIFEScreenshotAnnotatorView *screenshotAnnotatorView;

@end

@implementation LIFEImageEditorView

- (instancetype)initWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage
{
    self = [super init];
    if (self) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
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
        _imageBorderView.backgroundColor = tintColor;
        
        _screenshotAnnotatorView = [[LIFEScreenshotAnnotatorView alloc] initWithAnnotatedImage:annotatedImage];
        [_screenshotAnnotatorView setToolbarsHidden:YES animated:NO completion:nil];
        
        NSArray *customViews = @[_backgroundView, _cancelButton, _nextButton, _imageBorderView, _screenshotAnnotatorView];
        
        for (UIView *view in customViews) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [_backgroundView life_makeEdgesEqualTo:self];
        
        // Top button constraints
        
        [NSLayoutConstraint activateConstraints:@[
                                                  [_cancelButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
                                                  [_cancelButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:26],
                                                  [_nextButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
                                                  [_nextButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:26]
                                                  ]];
        
        // Image constraints
        
        // On iPhone 7 Plus, the image is 1545px high (out of 2208px high screen, in portrait mode)
//        CGFloat multiplier = (1545.0f / 2208.0f);
        CGFloat aspectRatio = [LIFEUIImage life_aspectRatio:annotatedImage.sourceImage];
        CGFloat toolbarHeight = 50;
        CGFloat navbarHeight = 44;
        CGFloat statusBarHeight = 20;
        CGFloat arbitraryMargin = 10;
        CGFloat verticalMargin = (toolbarHeight + navbarHeight + statusBarHeight + arbitraryMargin); // Toolbar + nav + status bar
        
        [NSLayoutConstraint activateConstraints:@[
            [_screenshotAnnotatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_screenshotAnnotatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:(statusBarHeight / 2.0f)],
            [_screenshotAnnotatorView.widthAnchor constraintEqualToAnchor:_screenshotAnnotatorView.heightAnchor multiplier:aspectRatio],
            [_screenshotAnnotatorView.heightAnchor constraintEqualToAnchor:self.heightAnchor constant:-verticalMargin]
            ]];
        
        // Make the image border view just a bit bigger than the image
        
        [_imageBorderView life_makeEdgesEqualTo:_screenshotAnnotatorView withInset:-kImageBorderWidth];
        
        
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
        
        [NSLayoutConstraint activateConstraints:@[
                                                  [toolButtons.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
                                                  [toolButtons.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.75],
                                                  [toolButtons.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
                                                  [toolButtons.heightAnchor constraintEqualToConstant:toolbarHeight]
                                                  ]];
    }
    return self;
}

#pragma mark - Private methods

+ (nonnull UIColor *)_buttonTintColor
{
    return [UIColor blueColor];
}

@end
