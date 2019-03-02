//
//  LIFEImageEditorSegmentedControl.m
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

#import "LIFEImageEditorSegmentedControl.h"
#import "UIImage+LIFEAdditions.h"
#import "LIFEMacros.h"
#import "LIFEAppearanceImpl.h"
#import "UIColor+LIFEAdditions.h"
#import "UIView+LIFEAdditions.h"

@interface LIFEImageEditorSegmentedControl ()

@property (nonatomic, readonly) NSInteger selectedSegmentIndex;
@property (nonnull, nonatomic) LIFEToolButton *arrowButton;
@property (nonnull, nonatomic) LIFEToolButton *loupeButton;
@property (nonnull, nonatomic) LIFEToolButton *blurButton;
@property (nonnull, nonatomic) NSArray<LIFEToolButton *> *buttons;

@end

@implementation LIFEImageEditorSegmentedControl

- (instancetype)init
{
    self = [super init];
    if (self) {
        let arrowButton = [[LIFEToolButton alloc] init];
        arrowButton.imageView.image = [LIFEUIImage life_arrowToolbarIcon];
        arrowButton.titleView.text = LIFELocalizedString(LIFEStringKey_ArrowToolLabel);
        
        let loupeButton = [[LIFEToolButton alloc] init];
        loupeButton.imageView.image = [LIFEUIImage life_loupeIcon];
        loupeButton.titleView.text = LIFELocalizedString(LIFEStringKey_LoupeToolLabel);
        
        let blurButton = [[LIFEToolButton alloc] init];
        blurButton.imageView.image = [LIFEUIImage life_pixelateIcon];
        blurButton.titleView.text = LIFELocalizedString(LIFEStringKey_BlurToolLabel);
        
        let freeformButton = [[LIFEToolButton alloc] init];
        freeformButton.imageView.image = [LIFEUIImage life_penToolbarIcon];
        freeformButton.titleView.text = LIFELocalizedString(LIFEStringKey_FreeformToolLabel);
        
        _buttons = @[arrowButton, loupeButton, blurButton, freeformButton];
        
        id<LIFEAppearance> appearance = [LIFEAppearanceImpl sharedAppearance];
        UIColor *tintColor = appearance.tintColor;
        
        for (LIFEToolButton *button in _buttons) {
            UIColor *normalColor = [tintColor life_grayscale];
            [button setTintColor:normalColor forState:UIControlStateNormal];
            [button setTintColor:tintColor forState:UIControlStateSelected];
            [button addTarget:self action:@selector(_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:_buttons];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.distribution = UIStackViewDistributionFillEqually;
        stackView.alignment = UIStackViewAlignmentFill;
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:stackView];
        [stackView life_makeEdgesEqualTo:self];
        
        self.selectedSegmentIndex = 0; // Make sure the arrow is already selected
    }
    return self;
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    _selectedSegmentIndex = selectedSegmentIndex;
    
    for (NSInteger i = 0; i < _buttons.count; i++) {
        LIFEToolButton *button = _buttons[i];
        button.selected = (i == _selectedSegmentIndex);
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (_didChangeHandler) {
        _didChangeHandler(self.selectedTool);
    }
}

- (LIFEToolButtonType)selectedTool
{
    return (LIFEToolButtonType)_selectedSegmentIndex;
}

- (void)_buttonTapped:(LIFEToolButton *)button
{
    NSUInteger index = [_buttons indexOfObject:button];
    NSParameterAssert(index != NSNotFound);
    self.selectedSegmentIndex = index;
}

@end
