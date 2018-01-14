//
//  LIFEToastViewController.m
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

#import "LIFEToastViewController.h"
#import "LIFEToastView.h"
#import "LIFEMacros.h"

static let kPaddingX = 10.0f;
static let kPaddingY = 10.0f;

@interface LIFEToastViewController ()

@property (nonnull, nonatomic) LIFEToastView *toastView;
@property (nonnull, nonatomic) NSLayoutConstraint *bottomConstraint;

@end

@implementation LIFEToastViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _toastView = [[LIFEToastView alloc] init];
    _toastView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_toastView];
    [NSLayoutConstraint activateConstraints:@[
        [_toastView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kPaddingX],
        [_toastView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kPaddingX]
        ]];
    
    _bottomConstraint = [_toastView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:100];
    _bottomConstraint.active = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _bottomConstraint.constant = -kPaddingY;

    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.9 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

@end
