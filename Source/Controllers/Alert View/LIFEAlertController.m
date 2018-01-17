//
//  LIFEContainerAlertToImageEditorAnimator.m
//  Copyright (C) 2017-2018 Buglife, Inc.
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

#import "LIFEAlertController.h"
#import "LIFEAlertAnimator.h"
#import "LIFEAlertView.h"
#import "LIFEAlertAction.h"
#import "LIFEContainerViewController.h"
#import "LIFEMacros.h"

@interface LIFEAlertController () <LIFEAlertViewDelegate>

@property (nonnull, nonatomic) LIFEAlertView *alertView;
@property (nullable, nonatomic) NSLayoutConstraint *alertViewWidthConstraint;

@end

@implementation LIFEAlertController

+ (nonnull instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    return [[LIFEAlertController alloc] initWithTitle:title];
}

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title
{
    self = [super init];
    if (self) {
        _alertView = [[LIFEAlertView alloc] initWithTitle:title];
        _alertView.delegate = self;
    }
    return self;
}

- (void)setImage:(nullable UIImage *)image
{
    [_alertView setImage:image];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.alertView];
    self.alertView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.alertView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.alertView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
        ]];
    
    _alertViewWidthConstraint = [self.alertView.widthAnchor constraintEqualToConstant:270];
    _alertViewWidthConstraint.active = YES;
    
    [self setDarkOverlayHidden:NO];
}

- (BOOL)modalPresentationCapturesStatusBarAppearance
{
    return NO;
}

#pragma mark - Animation

- (void)prepareExpandToDismissTransition
{
    _alertViewWidthConstraint.constant = self.view.bounds.size.width * 2.0;
}

#pragma mark - Public methods

- (void)addAction:(nonnull LIFEAlertAction *)action
{
    [self.alertView addAction:action];
}

- (void)setDarkOverlayHidden:(BOOL)hidden
{
    if (hidden) {
        self.view.backgroundColor = [UIColor clearColor];
    } else {
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
}

#pragma mark - LIFEAlertViewDelegate

- (void)alertViewDidSelectAction:(nonnull LIFEAlertAction *)action
{
    if (action.style == UIAlertActionStyleCancel) {
        [self _dismissSelfAnimated:YES completion:^{
            action.handler(action);
        }];
    } else {
        action.handler(action);
    }
}

#pragma mark - Private methods

- (void)_dismissSelfAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion
{
    if ([self.parentViewController isKindOfClass:[LIFEContainerViewController class]]) {
        let container = (LIFEContainerViewController *)self.parentViewController;
        [container life_dismissEverythingAnimated:flag completion:completion];
    } else {
        [self.parentViewController dismissViewControllerAnimated:flag completion:completion];
    }
}

@end
