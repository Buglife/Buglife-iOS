//
//  LIFEWhatHappenedView.m
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

#import "LIFEWhatHappenedTextView.h"
#import "UITableView+LIFEAdditions.h"
#import "UITextView+LIFEAdditions.h"
#import "NSString+LIFEAdditions.h"
#import "UIColor+LIFEAdditions.h"

static const CGFloat kInputViewPaddingX = 10;
static const CGFloat kInputViewPaddingY = 12;
static CGFloat SNRInputViewWidthForBoundsWidth(CGFloat boundsWidth);

@interface LIFEWhatHappenedTextView () <UITextViewDelegate>

/**
 Subclassing UITextView directly was causing problems w/ RTL support (maybe something to do w/ embedding
 a a UITextView/UIScrollView subclass using Auto Layout directly into a UITableViewCell). Thus the
 actual textView is a property/subview instead
 */
@property (nonatomic) UITextView *textViewImpl;
@property (nonatomic) UILabel *placeholderView;

// this is kinda shitty to have as mutable state,
// but we need it to change the row height when the text changes
@property (nonatomic) CGFloat cachedTextHeight;
@property (nonatomic) NSLayoutConstraint *placeholderViewLeadingConstraint;
@property (nonatomic) NSLayoutConstraint *placeholderViewTrailingConstraint;

@end

@implementation LIFEWhatHappenedTextView

@dynamic placeholderText;

#pragma mark - UITableViewCell overrides

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textViewImpl = [[UITextView alloc] init];
        _textViewImpl.delegate = self;
        _textViewImpl.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _textViewImpl.scrollEnabled = YES;
        _textViewImpl.backgroundColor = [UIColor clearColor];
        _textViewImpl.keyboardAppearance = UIKeyboardAppearanceDark;
        _textViewImpl.textContainerInset = UIEdgeInsetsMake(kInputViewPaddingY, kInputViewPaddingX, kInputViewPaddingY, kInputViewPaddingX);
    
        [self addSubview:_textViewImpl];
        
        _placeholderView = [[UILabel alloc] init];
        _placeholderView.numberOfLines = 0;
        _placeholderView.lineBreakMode = NSLineBreakByWordWrapping;
        _placeholderView.textColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.80 alpha:1];
        _placeholderView.backgroundColor = [UIColor clearColor];
        _placeholderView.isAccessibilityElement = NO;
        [self addSubview:_placeholderView];

        
        // Auto Layout
        
        _textViewImpl.translatesAutoresizingMaskIntoConstraints = NO;
        _placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_textViewImpl.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [_textViewImpl.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [_textViewImpl.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [_textViewImpl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        
        [_placeholderView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kInputViewPaddingY].active = YES;
        
        _placeholderViewLeadingConstraint = [_placeholderView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
        _placeholderViewTrailingConstraint = [_placeholderView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor];
        
        _placeholderViewLeadingConstraint.active = YES;
        _placeholderViewTrailingConstraint.active = YES;
        
//        _placeholderView.backgroundColor = [LIFEUIColor life_debugColorWithAlpha:0.25];
        
        [self bringSubviewToFront:_textViewImpl];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return [_textViewImpl canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [_textViewImpl becomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
    return [_textViewImpl canResignFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [_textViewImpl resignFirstResponder];
}

#pragma mark - Accessors

- (void)setText:(NSString *)text
{
    _textViewImpl.text = text;
    [self _updatePlaceholderView];
}

- (NSString *)text
{
    return _textViewImpl.text;
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderView.text = placeholderText;
    _placeholderView.textAlignment = [placeholderText life_naturalTextAligment];
    
    CGFloat leadingConstant = kInputViewPaddingX + 5;
    CGFloat trailingConstant = -leadingConstant;
    
    _placeholderViewLeadingConstraint.constant = leadingConstant;
    _placeholderViewTrailingConstraint.constant = trailingConstant;
}

- (NSString *)placeholderText
{
    return _placeholderView.text;
}

#pragma mark - Public methods

- (LIFEWhatHappenedTableViewCell *)tableViewCell
{
    UIView *superview = self.superview;
    
    while (superview != nil) {
        if ([superview isKindOfClass:[LIFEWhatHappenedTableViewCell class]]) {
            return (LIFEWhatHappenedTableViewCell *)superview;
        }
        
        superview = superview.superview;
    }
    
    return nil;
}

+ (CGFloat)heightForText:(NSString *)text withWidth:(CGFloat)parentViewWidth
{
    // The minimum height of this view is equal to 4 blank lines of text
    CGFloat minHeight = [self _heightForText:@"\n\n" withWidth:parentViewWidth];
    CGFloat currentTextHeight = [self _heightForText:text withWidth:parentViewWidth];
    return MAX(minHeight, currentTextHeight);
}

+ (CGFloat)_heightForText:(NSString *)text withWidth:(CGFloat)parentViewWidth
{
    // Add 1 extra blank line of padding,
    // if the last line has any text
    NSString *lastLine = [text componentsSeparatedByString:@"\n"].lastObject;
    
    if (lastLine.length > 0) {
        text = [text stringByAppendingString:@"\n"];
    }
    
    CGFloat inputViewWidth = SNRInputViewWidthForBoundsWidth(parentViewWidth);
    CGFloat inputViewHeight = [LIFEUITextView boundingHeightForText:text width:inputViewWidth font:[self _defaultFont]];
    CGFloat arbitraryBottomPadding = 17;
    CGFloat result = inputViewHeight + (2 * kInputViewPaddingY) + arbitraryBottomPadding;
    return result;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.textAlignment = LIFENSTextAlignmentForTextFieldOrTextView(textView);
}

- (void)textViewDidChange:(UITextView *)textView
{
    LIFEFixRTLForTextViewOrTextField(textView);
    [self _updatePlaceholderView];
    [self.lifeDelegate whatHappenedTextViewDidChange:self];
}

#pragma mark - Private methods

- (void)_updatePlaceholderView
{
    BOOL inputViewIsEmpty = (self.textViewImpl.text.length == 0);
    self.placeholderView.hidden = !inputViewIsEmpty;
}

+ (UIFont *)_defaultFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}


@end

CGFloat SNRInputViewWidthForBoundsWidth(CGFloat boundsWidth)
{
    return boundsWidth - (2 * kInputViewPaddingX);
}






@implementation LIFEWhatHappenedTableViewCell

#pragma mark - UIView stuff

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textView = [[LIFEWhatHappenedTextView alloc] init];
        [self.contentView addSubview:_textView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textView.frame = self.contentView.bounds;
}

- (BOOL)becomeFirstResponder
{
    return [_textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [_textView resignFirstResponder];
}

#pragma mark - Class methods

+ (NSString *)defaultIdentifier
{
    return NSStringFromClass([self class]);
}

+ (CGFloat)heightWithText:(NSString *)text boundsWidth:(CGFloat)boundsWidth
{
    return [LIFEWhatHappenedTextView heightForText:text withWidth:boundsWidth];
}

@end










@implementation LIFEWhatHappenedHeightCache
{
    CGFloat _height;
}

- (void)setHeightWithText:(NSString *)text inTableView:(UITableView *)tableView
{
    CGFloat boundsWidth = CGRectGetWidth(tableView.bounds);
    CGFloat newRowHeight = [LIFEWhatHappenedTableViewCell heightWithText:text boundsWidth:boundsWidth];
    
    BOOL shouldChangeRowHeight = ABS(_height - newRowHeight) > 2.0;
    _height = newRowHeight;
    
    if (shouldChangeRowHeight) {
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

@end
