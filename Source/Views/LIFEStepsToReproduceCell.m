//
//  LIFEStepsToReproduceCell.m
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

#import "LIFEStepsToReproduceCell.h"
#import "LIFEReproStep.h"
#import "UITableView+LIFEAdditions.h"
#import "UITextView+LIFEAdditions.h"
#import "NSString+LIFEAdditions.h"
#import "UIColor+LIFEAdditions.h"

static const CGFloat kNumberLabelPaddingX = 12;
static const CGFloat kNumberLabelWidth = 24;
static const CGFloat kInputViewPaddingX = 10;
static const CGFloat kInputViewPaddingY = 3;
static const CGFloat kInputViewContainerInsetTop = 8;
static const CGFloat kInputViewContainerInsetBottom = 8;

CGFloat LIFEInputViewOriginX(void);
CGFloat LIFEInputViewWidthForBoundsWidth(CGFloat boundsWidth);

@interface LIFEStepsToReproduceCell () <UITextViewDelegate>

@property (nonatomic) UILabel *numberLabel;
@property (nonatomic) UITextView *inputView;

@end

@implementation LIFEStepsToReproduceCell

#pragma mark - Public methods

+ (nonnull NSString *)defaultIdentifier
{
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [[self class] _fontForInputView];
        _numberLabel.textColor = [UIColor lightGrayColor];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_numberLabel];
        
        _inputView = [[UITextView alloc] init];
        _inputView.delegate = self;
        _inputView.font = [[self class] _fontForInputView];
        _inputView.scrollEnabled = NO; // This is required for UITextView to work w/ Auto Layout! (for our purposes, at least)
        _inputView.backgroundColor = [UIColor clearColor];
        _inputView.returnKeyType = UIReturnKeyNext;
        _inputView.keyboardAppearance = UIKeyboardAppearanceDark;
        [_inputView sizeToFit];
        [self.contentView addSubview:_inputView];
        
        _numberLabel.isAccessibilityElement = YES;
        _inputView.isAccessibilityElement = YES;
        self.isAccessibilityElement = NO;
        
        _numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _inputView.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat numberLabelWidth = kNumberLabelPaddingX + kNumberLabelWidth + kInputViewPaddingX;
        CGFloat numberLabelY = kInputViewPaddingY + kInputViewContainerInsetTop;
        
        [_numberLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:kNumberLabelPaddingX].active = YES;
        [_numberLabel.widthAnchor constraintEqualToConstant:numberLabelWidth].active = YES;
        [_numberLabel.trailingAnchor constraintEqualToAnchor:_inputView.leadingAnchor constant:0].active = YES;
        [_numberLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:numberLabelY].active = YES;
        
        [_inputView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-kInputViewPaddingX].active = YES;
        [_inputView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kInputViewPaddingY].active = YES;
    }
    return self;
}

- (BOOL)becomeFirstResponder
{
    return [self.inputView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [self.inputView resignFirstResponder];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.reproStep = nil;
    self.delegate = nil;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.textAlignment = LIFENSTextAlignmentForTextFieldOrTextView(textView);
}

- (void)textViewDidChange:(UITextView *)textView
{
    // RTL
    LIFEFixRTLForTextViewOrTextField(textView);
    
    // Update the model
    self.reproStep.userDescription = textView.text;
    
    // Then update the tableView
    UITableView *tableView = [LIFEUITableViewCell tableViewForCell:self];
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    if ([replacementText isEqualToString:@"\n"]) {
        [self.delegate stepsToReproduceCellDidReturn:self];
        return NO;
    }
    
    return YES;
}

#pragma mark - Accessors

- (void)setReproStep:(LIFEReproStep *)reproStep
{
    if (_reproStep != reproStep) {
        _reproStep = reproStep;
        self.inputView.text = _reproStep.userDescription;
    }
}

- (void)setStepNumber:(NSUInteger)stepNumber
{
    self.numberLabel.text = [NSString stringWithFormat:@"%lu.", (unsigned long)stepNumber];
    self.numberLabel.accessibilityLabel = [NSString stringWithFormat:@"Step %lu", (unsigned long)stepNumber];
}

#pragma mark - Height calculation

+ (CGFloat)heightWithReproStep:(LIFEReproStep *)reproStep boundsWidth:(CGFloat)boundsWidth
{
    NSString *text = reproStep.userDescription;
    text = [text stringByAppendingString:@"\n"];    // append line break so we get that extra blank line
    UIFont *font = [self _fontForInputView];
    CGFloat textViewWidth = LIFEInputViewWidthForBoundsWidth(boundsWidth);
    CGFloat textViewHeight = [LIFEUITextView boundingHeightForText:text width:textViewWidth font:font];
    CGFloat totalHeight = ceil(textViewHeight) + (2 * kInputViewPaddingY) + kInputViewContainerInsetTop + kInputViewContainerInsetBottom;
    
    totalHeight = MAX(totalHeight, 44);
    
    return totalHeight;
}

CGFloat LIFEInputViewOriginX()
{
    return kNumberLabelPaddingX + kNumberLabelWidth + kInputViewPaddingX;
}

CGFloat LIFEInputViewWidthForBoundsWidth(CGFloat boundsWidth)
{
    return boundsWidth - LIFEInputViewOriginX() - kInputViewPaddingX;
}
                              
#pragma mark - Other private methods
                              
+ (UIFont *)_fontForInputView
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
