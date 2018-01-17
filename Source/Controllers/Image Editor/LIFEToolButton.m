//
//  LIFEToolButton.m
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

#import "LIFEToolButton.h"
#import "LIFEMacros.h"

let kImageHeight = 23.0f;

@interface LIFEToolButton ()

@property (nonnull, nonatomic) NSLayoutConstraint *imageCenterX;
@property (nonnull, nonatomic) NSLayoutConstraint *imageBottom;
@property (nonnull, nonatomic) NSLayoutConstraint *imageWidth;
@property (nonnull, nonatomic) NSLayoutConstraint *imageHeight;
@property (nonnull, nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *controlStateTintColors;

@end

@implementation LIFEToolButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        _controlStateTintColors = [[NSMutableDictionary alloc] init];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _titleView = [[UILabel alloc] init];
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.font = [UIFont systemFontOfSize:10];
        
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _titleView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_imageView];
        [self addSubview:_titleView];
        
//        _imageView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
//        _titleView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.25];
//        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.25];
        
        let imageScale = 0.75f;
        
        _imageCenterX = [_imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor];
        _imageBottom = [_imageView.bottomAnchor constraintEqualToAnchor:_titleView.topAnchor constant:-5.0];
        _imageWidth = [_imageView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:imageScale];
        _imageHeight = [_imageView.heightAnchor constraintEqualToConstant:kImageHeight];
        
        [NSLayoutConstraint activateConstraints:@[_imageCenterX, _imageBottom, _imageWidth, _imageHeight]];
        
        [NSLayoutConstraint activateConstraints:@[
            [_titleView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_titleView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-1.0],
            [_titleView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
            ]];
    }
    return self;
}

- (void)setTintColor:(nonnull UIColor *)tintColor forState:(UIControlState)state
{
    _controlStateTintColors[@(state)] = tintColor;
    [self _updateCurrentTintColor];
}

- (nullable UIColor *)_tintColorForState:(UIControlState)state
{
    if (state & UIControlStateHighlighted) {
        let color = _controlStateTintColors[@(UIControlStateHighlighted)];
        
        if (color) {
            return color;
        }
    }
    
    if (state & UIControlStateSelected) {
        let color = _controlStateTintColors[@(UIControlStateSelected)];
        
        if (color) {
            return color;
        }
    }
    
    return _controlStateTintColors[@(UIControlStateNormal)];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self _updateCurrentTintColor];
}

- (void)_updateCurrentTintColor
{
    UIColor *tintColor = [self _tintColorForState:self.state];
    _imageView.tintColor = tintColor;
    _titleView.textColor = tintColor;
}

@end
