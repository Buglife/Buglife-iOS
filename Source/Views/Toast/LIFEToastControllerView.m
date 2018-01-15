//
//  LIFEToastControllerView.m
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

#import "LIFEToastControllerView.h"
#import "LIFEToastView.h"
#import "UIView+LIFEAdditions.h"
#import "LIFEMacros.h"

static let kPaddingX = 10.0f;
static let kPaddingY = 10.0f;

@interface LIFEToastControllerView ()

@property (nonnull, nonatomic) LIFEToastView *toastView;
@property (nonnull, nonatomic) NSLayoutConstraint *bottomConstraint;

@end

@implementation LIFEToastControllerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _toastView = [[LIFEToastView alloc] init];
        _toastView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_toastView];
        [NSLayoutConstraint activateConstraints:@[
                                                  [_toastView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:kPaddingX],
                                                  [_toastView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-kPaddingX]
                                                  ]];
        
        _bottomConstraint = [_toastView.bottomAnchor constraintEqualToAnchor:self.life_safeAreaLayoutGuideBottomAnchor constant:LIFEToastControllerViewDismissedOffsetY];
        _bottomConstraint.active = YES;
    }
    return self;
}

- (void)setToastViewOffsetY:(CGFloat)offsetY
{
    _toastViewOffsetY = offsetY;
    _bottomConstraint.constant = (-kPaddingY) + offsetY;;
}

// Unless a touch event hits an actual subview,
// let it pass through to whatever's behind. This allows things like
// LIFEToastView to remain onscreen while allowing the host app to
// receive touches.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

@end
