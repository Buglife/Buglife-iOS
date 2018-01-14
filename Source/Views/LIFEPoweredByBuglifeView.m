//
//  LIFEPoweredByBuglifeView.m
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

#import "LIFEPoweredByBuglifeView.h"
#import "UIImage+LIFEAdditions.h"
#import "LIFEMacros.h"
#import "NSString+LIFEAdditions.h"

static const CGFloat kTextLabelBugIconSpacing = 5;
static const CGFloat kBugIconOffsetY = 1;

@interface LIFEPoweredByBuglifeView ()

@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UIImageView *bugIcon;

@end

@implementation LIFEPoweredByBuglifeView

@synthesize foregroundColor = _foregroundColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.text = LIFELocalizedString(LIFEStringKey_PoweredByBuglife);
        _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        [_textLabel sizeToFit];
        [self addSubview:_textLabel];
        
        _bugIcon = [[UIImageView alloc] init];
        _bugIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_bugIcon];
        
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _bugIcon.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImage *image = self.dragonflyIcon;
        CGSize bugIconSize = CGSizeMake(image.size.width / 2.0, image.size.height / 2.0);
        CGFloat textLabelXoffset = -(bugIconSize.width / 2.0);
        
        if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:_textLabel.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft) {
            textLabelXoffset = -textLabelXoffset;
        }
        
        [_textLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:textLabelXoffset].active = YES;
        [_textLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        
        [_bugIcon.leadingAnchor constraintEqualToAnchor:_textLabel.trailingAnchor constant:kTextLabelBugIconSpacing].active = YES;
        [_bugIcon.centerYAnchor constraintEqualToAnchor:_textLabel.centerYAnchor constant:kBugIconOffsetY].active = YES;
        [_bugIcon.widthAnchor constraintEqualToConstant:bugIconSize.width].active = YES;
        [_bugIcon.heightAnchor constraintEqualToConstant:bugIconSize.height].active = YES;
        
        [self _updateContent];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, [[self class] defaultHeight]);
}

#pragma mark - Public methods

- (void)setForegroundColor:(UIColor *)foregroundColor
{
    _foregroundColor = foregroundColor;
    [self _updateContent];
}

- (UIColor *)foregroundColor
{
    if (_foregroundColor == nil) {
        _foregroundColor = [UIColor grayColor];
    }

    return _foregroundColor;
}

+ (CGFloat)defaultHeight
{
    return 60;
}

- (void)_updateContent
{
    _textLabel.textColor = self.foregroundColor;
    _bugIcon.image = self.dragonflyIcon;
}

- (nonnull UIImage *)dragonflyIcon
{
    return [UIImage life_dragonflyIconWithColor:self.foregroundColor];
}

@end
