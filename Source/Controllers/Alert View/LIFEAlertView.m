//
//  LIFEAlertView.m
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

#import "LIFEAlertView.h"
#import "UIView+LIFEAdditions.h"
#import "LIFEAlertActionView.h"
#import "LIFEAlertAction.h"
#import "UIImage+LIFEAdditions.h"
#import "LIFEPoweredByBuglifeView.h"
#import "LIFEMacros.h"

let kAlertViewCornerRadius = 10.0f;
let kTitleViewPaddingX = 16.0f;
let kTitleViewPaddingY = 19.0f;
let kImagePaddingTop = 16.0f;
let kImagePaddingBottom = 16.0f;

@interface LIFEAlertView ()

@property (nonnull, nonatomic) UIView *backgroundView;
@property (nonnull, nonatomic) UILabel *titleLabel;
@property (nonnull, nonatomic) UIImageView *imageView;
@property (nonnull, nonatomic) UIStackView *actionButtonStack;

@property (nonnull, nonatomic) NSMutableArray<LIFEAlertActionView *> *actionButtons;
@property (nonnull, nonatomic) NSMutableArray<LIFEAlertAction *> *actions;

@end

@interface LIFEAlertActionSeparatorView : UIView

+ (nonnull UIColor *)defaultColor;

@end

@implementation LIFEAlertView

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title
{
    self = [super init];
    if (self) {
        _actionButtons = [[NSMutableArray alloc] init];
        _actions = [[NSMutableArray alloc] init];
        
        self.backgroundColor = [UIColor clearColor];
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        _backgroundView.layer.masksToBounds = YES;
        _backgroundView.layer.cornerRadius = kAlertViewCornerRadius;
        [self addSubview:_backgroundView];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [_backgroundView life_makeEdgesEqualTo:self];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = title;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_backgroundView addSubview:_titleLabel];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.layer.borderColor = [LIFEAlertActionSeparatorView defaultColor].CGColor;
        _imageView.layer.borderWidth = 1.0;
        [_backgroundView addSubview:_imageView];
        
        let separator = [[LIFEAlertActionSeparatorView alloc] init];
        _actionButtonStack = [[UIStackView alloc] initWithArrangedSubviews:@[separator]];
        _actionButtonStack.translatesAutoresizingMaskIntoConstraints = NO;
        _actionButtonStack.axis = UILayoutConstraintAxisVertical;
        _actionButtonStack.distribution = UIStackViewDistributionFillProportionally;
        _actionButtonStack.alignment = UIStackViewAlignmentFill;
        [_backgroundView addSubview:_actionButtonStack];
        
        let poweredView = [[LIFEPoweredByBuglifeView alloc] init];
        poweredView.translatesAutoresizingMaskIntoConstraints = NO;
        poweredView.foregroundColor = [UIColor whiteColor];
        [self addSubview:poweredView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor constant:kTitleViewPaddingX],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor constant:-kTitleViewPaddingX],
            [_titleLabel.topAnchor constraintEqualToAnchor:_backgroundView.topAnchor constant:kTitleViewPaddingY],
            [_imageView.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:kImagePaddingTop],
            [_imageView.centerXAnchor constraintEqualToAnchor:_titleLabel.centerXAnchor],
            [_imageView.widthAnchor constraintEqualToAnchor:_backgroundView.widthAnchor multiplier:0.4],
            [_actionButtonStack.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor constant:kImagePaddingBottom],
            [_actionButtonStack.leadingAnchor constraintEqualToAnchor:_backgroundView.leadingAnchor],
            [_actionButtonStack.trailingAnchor constraintEqualToAnchor:_backgroundView.trailingAnchor],
            [_actionButtonStack.bottomAnchor constraintEqualToAnchor:_backgroundView.bottomAnchor],
            [poweredView.topAnchor constraintEqualToAnchor:_backgroundView.bottomAnchor constant:-10],
            [poweredView.centerXAnchor constraintEqualToAnchor:_backgroundView.centerXAnchor],
            ]];
    }
    return self;
}

- (void)setBackgroundViewBackgroundColor:(UIColor *)backgroundColor
{
    self.backgroundView.backgroundColor = backgroundColor;
}

- (void)setImage:(nullable UIImage *)image
{
    _imageView.image = image;
    
    if (image != nil) {
        let imageAspectRatio = [LIFEUIImage life_aspectRatio:image];
        [_imageView.widthAnchor constraintEqualToAnchor:_imageView.heightAnchor multiplier:imageAspectRatio].active = YES;
    }
}

- (void)addAction:(nonnull LIFEAlertAction *)action
{
    let actionButton = [[LIFEAlertActionView alloc] initWithTitle:action.title style:action.style];
    [_actionButtonStack addArrangedSubview:actionButton];
    
    [_actions addObject:action];
    [_actionButtons addObject:actionButton];
    
    [actionButton addTarget:self action:@selector(_actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    let separator = [[LIFEAlertActionSeparatorView alloc] init];
    [_actionButtonStack addArrangedSubview:separator];
}

- (void)performDismissTransition
{
    _titleLabel.alpha = 0;
    _actionButtonStack.alpha = 0;
}

- (void)_actionButtonTapped:(LIFEAlertActionView *)sender
{
    NSUInteger actionIndex = [_actionButtons indexOfObject:sender];
    LIFEAlertAction *action = _actions[actionIndex];
    [self.delegate alertViewDidSelectAction:action];
}

@end

@implementation LIFEAlertActionSeparatorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[self class] defaultColor];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 1);
}

+ (nonnull UIColor *)defaultColor
{
    return [UIColor colorWithWhite:(219.0/255.0) alpha:1];;
}

@end
