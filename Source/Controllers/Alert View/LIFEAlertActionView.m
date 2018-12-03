//
//  LIFEAlertActionView.m
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

#import "LIFEAlertActionView.h"
#import "UIImage+LIFEAdditions.h"
#import "LIFEMacros.h"
#import "LIFEAppearanceImpl.h"
#import "UIColor+LIFEAdditions.h"

let kIntrinsicHeight = 44.0f;
let kFontSize = 17.0f;

@interface LIFEAlertActionView ()

@property (nonnull, nonatomic) UILabel *titleLabel;

@end

@implementation LIFEAlertActionView

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title style:(LIFEAlertActionStyle)style
{
    self = [super init];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.text = title;
        
        if (style == UIAlertViewStyleDefault) {
            _titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
        } else {
            _titleLabel.font = [UIFont systemFontOfSize:kFontSize];
        }
        
        if (style == UIAlertActionStyleDestructive) {
            _titleLabel.textColor = [UIColor redColor];
        } else {
            UIColor *tintColor = [LIFEAppearanceImpl sharedAppearance].tintColor;
            BOOL isTintColorDark = ![tintColor life_isLightColor];
            UIColor *textColor;
            
            if (isTintColorDark) {
                textColor = tintColor;
            } else {
                textColor = [LIFEAppearanceImpl sharedAppearance].barTintColor;
            }
            
            _titleLabel.textColor = textColor;
        }
        
        [self addSubview:_titleLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
            ]];
        
        [self.heightAnchor constraintEqualToConstant:kIntrinsicHeight].active = YES;
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, kIntrinsicHeight);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [[self class] _highlightedBackgroundColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

+ (nonnull UIColor *)_highlightedBackgroundColor
{
    return [UIColor colorWithWhite:(235.0/255.0) alpha:1.0];
}

@end
