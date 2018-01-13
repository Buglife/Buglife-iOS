//
//  LIFEReportView.m
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

#import "LIFEReportView.h"
#import "LIFEAttachmentView.h"
#import "LIFEWhatHappenedTextView.h"
#import "UIColor+LIFEAdditions.h"

// this is shitty to hardcode
static const CGFloat kLayoutGuideOffset = 64.0;
static const CGFloat kAttachmentHeight = 44.0;

@interface LIFEReportView ()

@property (nonatomic) LIFEAttachmentButton *attachmentButton;
@property (nonatomic) UIView *separatorView;
@property (nonatomic) LIFEWhatHappenedTextView *whatHappenedTextView;

@end

@implementation LIFEReportView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _attachmentButton = [[LIFEAttachmentButton alloc] init];
        [self addSubview:_attachmentButton];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor life_colorWithHexValue:0xc8c7cc];
        [self addSubview:_separatorView];
        
        _whatHappenedTextView = [[LIFEWhatHappenedTextView alloc] init];
        NSParameterAssert(NO); // Not implemented. This class is deprecated I think
//        _whatHappenedTextView.bounces = YES;
//        _whatHappenedTextView.alwaysBounceVertical = YES;
        [self addSubview:_whatHappenedTextView];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds) - _bottomInset;
    
    {
        // attachment cell
        _attachmentButton.frame = CGRectMake(0, kLayoutGuideOffset, boundsWidth, kAttachmentHeight);
    }
    
    {
        // separator view
        _separatorView.frame = CGRectMake(0, CGRectGetMaxY(_attachmentButton.frame), boundsWidth, 0.5);
    }
    
    {
        // what happened text view
        CGFloat originY = CGRectGetMaxY(_separatorView.frame);
        originY = ceilf(originY);
        CGFloat height = boundsHeight - originY;
        _whatHappenedTextView.frame = CGRectMake(0, originY, boundsWidth, height);
    }
}

- (void)setBottomInset:(CGFloat)bottomInset
{
    _bottomInset = bottomInset;
    [self setNeedsLayout];
}

@end
