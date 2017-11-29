//
//  LIFETextFieldCellTableViewCell.m
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

#import "LIFETextFieldCell.h"
#import "NSString+LIFEAdditions.h"

static const CGFloat kTextFieldOffsetX = 16;

@interface LIFETextFieldCell () <UITextFieldDelegate>

@property (nonatomic) UITextField *textField;

@end

@implementation LIFETextFieldCell

#pragma mark - Initialization

+ (nonnull NSString *)defaultIdentifier
{
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.keyboardAppearance = UIKeyboardAppearanceDark;
        [_textField addTarget:self action:@selector(_textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:_textField];
        
        // Auto Layout
        
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_textField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kTextFieldOffsetX].active = YES;
        [_textField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kTextFieldOffsetX].active = YES;
        [_textField.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
        [_textField.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
        
        _textField.textAlignment = NSTextAlignmentNatural;
    }
    
    return self;
}

#pragma mark - UIResponder

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textAlignment = LIFENSTextAlignmentForTextFieldOrTextView(textField);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Always assumes `textField` is the email field.
    
    // We need to dispatch_async because otherwise, the 'return'
    // keypress gets sent to the next text field, *after* we've
    // switched focus to it
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate textFieldCellDidReturn:self];
    });
    
    return YES;
}

#pragma mark - Private methods

- (void)_textFieldDidChange:(id)sender
{
    LIFEFixRTLForTextViewOrTextField(sender);
    [self.delegate textFieldCellDidChange:self];
}

@end
