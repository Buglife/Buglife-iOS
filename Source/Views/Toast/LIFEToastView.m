//
//  LIFEToastView.m
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

#import "LIFEToastView.h"
#import "UIView+LIFEAdditions.h"
#import "UIColor+LIFEAdditions.h"
#import "UIImage+LIFEAdditions.h"
#import "LIFELocalizedStringProvider.h"
#import "LIFEAppearanceImpl.h"
#import "LIFEMacros.h"

static let kPaddingX = 30.0f;
static let kPaddingY = 23.0f;
static let kIconTextSpacing = 23.0f;

@interface LIFEToastView ()

@property (nonnull, nonatomic) UIVisualEffectView *blurView;
@property (nonnull, nonatomic) UIView *backgroundView;
@property (nonnull, nonatomic) UILabel *titleLabel;
@property (nonnull, nonatomic) UIImageView *dragonflyIconView;

@end

@implementation LIFEToastView

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIBlurEffectStyle blurStyle;
        
        if (@available(iOS 10.0, *)) {
            blurStyle = UIBlurEffectStyleProminent;
        } else {
            blurStyle = UIBlurEffectStyleExtraLight;
        }
        
        UIVisualEffect *blur = [UIBlurEffect effectWithStyle:blurStyle];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _blurView.translatesAutoresizingMaskIntoConstraints = NO;
        _blurView.layer.cornerRadius = 10;
        _blurView.layer.masksToBounds = YES;
        [self addSubview:_blurView];
        [_blurView life_makeEdgesEqualTo:self];
        
        id<LIFEAppearance> appearance = [LIFEAppearanceImpl sharedAppearance];
        UIColor *contentColor = [appearance tintColor];
        UIColor *backgroundColor = [appearance barTintColor];
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundView.backgroundColor = backgroundColor;
        [self addSubview:_backgroundView];
        [_backgroundView life_makeEdgesEqualTo:self];
        
        _blurView.hidden = YES;
        _backgroundView.hidden = YES;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.text = LIFELocalizedString(LIFEStringKey_ThanksForFilingABug);
        _titleLabel.textColor = contentColor;
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_titleLabel];
        
        UIImage *dragonflyIcon = [UIImage life_dragonflyIconWithColor:contentColor];
        _dragonflyIconView = [[UIImageView alloc] initWithImage:dragonflyIcon];
        _dragonflyIconView.translatesAutoresizingMaskIntoConstraints = NO;
        _dragonflyIconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_dragonflyIconView];
        
        let dragonflyScale = 0.75;
        let dragonflyWidth = dragonflyIcon.size.width * dragonflyScale;
        let dragonflyHeight = dragonflyIcon.size.height * dragonflyWidth;
        [_dragonflyIconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:kPaddingX].active = YES;
        [_dragonflyIconView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [_dragonflyIconView.widthAnchor constraintEqualToConstant:dragonflyWidth].active = YES;
        [_dragonflyIconView.heightAnchor constraintEqualToConstant:dragonflyHeight].active = YES;
        
        
        [NSLayoutConstraint activateConstraints:@[
            [_dragonflyIconView.trailingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor constant:-kIconTextSpacing],
            [_dragonflyIconView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-kPaddingX],
            [_titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_titleLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor constant:-(kPaddingY * 2)]
            ]];
    }
    return self;
}

+ (UIColor *)backgroundColor
{
    id<LIFEAppearance> appearance = [LIFEAppearanceImpl sharedAppearance];
    return [appearance barTintColor];
}

+ (nonnull UIColor *)_contentColor
{
    return [UIColor life_colorWithHexValue:0x595859];
}

@end
