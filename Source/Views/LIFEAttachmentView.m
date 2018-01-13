//
//  LIFEAttachmentView.m
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

#import "LIFEAttachmentView.h"
#import "UIImage+LIFEAdditions.h"
#import "UIColor+LIFEAdditions.h"
#import "LIFEMacros.h"

@interface LIFEAttachmentView ()

@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UIImageView *screenshotView;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) UIImageView *disclosureIndicatorView;

@end

static const CGFloat kScreenshotViewPadding = 5;

@implementation LIFEAttachmentView

@dynamic screenshot;

#pragma mark - Public methods

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _screenshotView = [[UIImageView alloc] init];
        _screenshotView.contentMode = UIViewContentModeScaleAspectFill;
        _screenshotView.clipsToBounds = YES;
        _screenshotView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _screenshotView.layer.borderWidth = 1;
        [self addSubview:_screenshotView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:_activityIndicatorView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self addSubview:_textLabel];
        
        _disclosureIndicatorView = [[UIImageView alloc] init];
        _disclosureIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_disclosureIndicatorView];
        
        // Auto Layout
        _screenshotView.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _disclosureIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_screenshotView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:kScreenshotViewPadding].active = YES;
        [_screenshotView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kScreenshotViewPadding].active = YES;
        [_screenshotView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-kScreenshotViewPadding].active = YES;
        [_screenshotView.heightAnchor constraintEqualToAnchor:_screenshotView.widthAnchor].active = YES;
        
        [_activityIndicatorView.centerXAnchor constraintEqualToAnchor:_screenshotView.centerXAnchor].active = YES;
        [_activityIndicatorView.centerYAnchor constraintEqualToAnchor:_screenshotView.centerYAnchor].active = YES;
        
        [_disclosureIndicatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16].active = YES;
        [_disclosureIndicatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [_disclosureIndicatorView.widthAnchor constraintEqualToConstant:8].active = YES;
        
        [_textLabel.leadingAnchor constraintEqualToAnchor:_screenshotView.trailingAnchor constant:10].active = YES;
        [_textLabel.trailingAnchor constraintEqualToAnchor:_disclosureIndicatorView.leadingAnchor].active = YES;
        [_textLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [_textLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    }
    
    return self;
}

- (UIImage *)screenshot
{
    return self.screenshotView.image;
}

- (void)setScreenshot:(UIImage *)screenshot
{
    self.screenshotView.image = screenshot;
}

- (void)setActivityIndicatorViewIsAnimating:(BOOL)animating
{
    if (animating) {
        _screenshotView.backgroundColor = [UIColor blackColor];
        [_activityIndicatorView startAnimating];
    } else {
        [_activityIndicatorView stopAnimating];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    UIImage *disclosureIndicatorImage = [LIFEUIImage life_disclosureIndicatorIcon];
    
    if (self.semanticContentAttribute != UISemanticContentAttributeForceLeftToRight) {
        disclosureIndicatorImage = disclosureIndicatorImage.imageFlippedForRightToLeftLayoutDirection;
    }
    
    _disclosureIndicatorView.image = disclosureIndicatorImage;
}

@end









@implementation LIFEAttachmentCell
{
    LIFEAttachmentView *_attachmentView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _attachmentView = [[LIFEAttachmentView alloc] init];
        [self.contentView addSubview:_attachmentView];

        self.accessibilityTraits = UIAccessibilityTraitStaticText | UIAccessibilityTraitButton;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _attachmentView.frame = self.contentView.bounds;
}

+ (CGSize)targetImageSize
{
    return CGSizeMake(88, 88);
}

+ (NSString *)defaultIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setThumbnailImage:(UIImage *)image
{
    _attachmentView.screenshot = image;
}

- (void)setTitle:(NSString *)title
{
    _attachmentView.textLabel.text = title;
}

- (void)setActivityIndicatorViewIsAnimating:(BOOL)animating
{
    [_attachmentView setActivityIndicatorViewIsAnimating:animating];
}

@end








@implementation LIFEAttachmentButton
{
    LIFEAttachmentView *_attachmentView;
}

@dynamic screenshot;

- (UIImage *)screenshot
{
    return _attachmentView.screenshot;
}

- (void)setScreenshot:(UIImage *)screenshot
{
    [_attachmentView setScreenshot:screenshot];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self _updateBackgroundColor];
}

- (void)setLifeSelected:(BOOL)lifeSelected
{
    _lifeSelected = lifeSelected;
    [self _updateBackgroundColor];
}

- (void)setLifeSelected:(BOOL)lifeSelected animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.15 animations:^{
            self.lifeSelected = lifeSelected;
        }];
    } else {
        self.lifeSelected = lifeSelected;
    }
}

#pragma mark - Private methods

- (void)_updateBackgroundColor
{
    if (self.isHighlighted || self.lifeSelected) {
        UIColor *selectionColor = [UIColor life_colorWithHexValue:0xd9d9d9]; // same color as UITableView grey selection
        self.backgroundColor = selectionColor;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end

