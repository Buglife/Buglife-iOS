//
//  LIFEBugButtonWindow.m
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

#import "LIFEBugButtonWindow.h"
#import "LIFEFloatingButton.h"
#import "LIFEUserDefaults.h"
#import "LIFESwizzler.h"

static NSString * const kCastbaBase64 = @"X2NhbkFmZmVjdFN0YXR1c0JhckFwcGVhcmFuY2U=";

typedef LIFEFloatingButton LIFEBugButton;

@interface LIFEBugButtonWindow ()

@property (nonatomic) LIFEBugButton *bugButton;

@end

@implementation LIFEBugButtonWindow

#pragma mark - UIView methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bugButton = [[LIFEBugButton alloc] init];
        [_bugButton addTarget:self action:@selector(_bugButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bugButton];
        
        self.isAccessibilityElement = NO;
        self.windowLevel = 2002;
        
        // rootViewController must be nil so that this window
        // doesn't affect rotation/status bar/etc.
        self.rootViewController = nil;
        
        LIFEMonkeyPatchBugButtonWindow();
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.bugButton.frame, point) && !self.bugButton.hidden) {
        return self.bugButton;
    }
    
    return nil;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    // Even if we're showing the bug button, fetching its center point is async, so hide it first before showing it
    self.bugButton.hidden = YES;
    
    if (!hidden) {
        [[LIFEUserDefaults sharedDefaults] getLastFloatingButtonCenterPointToQueue:dispatch_get_main_queue() completion:^(CGPoint centerPoint) {
            self.bugButton.center = centerPoint;
            self.bugButton.hidden = NO;
        }];
    }
}

#pragma mark - Public methods

- (void)setBugButtonHidden:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat duration = 0.15;
    CGAffineTransform transform = CGAffineTransformIdentity;
    LIFEBugButton *button = self.bugButton;
    
    if (hidden) {
        transform = CGAffineTransformMakeScale(0.05, 0.05);
    } else {
        // unhide it before animating the transform
        button.hidden = NO;
    }
    
    [UIView animateWithDuration:duration animations:^{
        button.transform = transform;
    } completion:^(BOOL finished) {
        button.hidden = hidden;
    }];
}

- (void)configureBugButtonWithForegroundColor:(nullable UIColor *)foregroundColor backgroundColor:(nullable UIColor *)backgroundColor
{
    self.bugButton.foregroundColor = foregroundColor;
    self.bugButton.backgroundColor = backgroundColor;
}

#pragma mark - Private

- (void)_bugButtonTapped:(id)sender
{
    NSParameterAssert(self.lifeDelegate);
    [self.lifeDelegate bugButtonWasTappedInWindow:self];
}

// Dynamically sets our own implementation for -[UIWindow _canAffectStatusBarAppearance]
static void LIFEMonkeyPatchBugButtonWindow() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *selName = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:kCastbaBase64 options:0] encoding:NSUTF8StringEncoding];
        SEL sel = NSSelectorFromString(selName);
        
        LIFEReplaceMethodWithBlock([LIFEBugButtonWindow class], sel, ^(LIFEBugButtonWindow *_self) {
            return NO;
        });
    });
}

@end
