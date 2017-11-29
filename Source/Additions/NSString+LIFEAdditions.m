//
//  NSString+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 12/12/16.
//
//

#import "NSString+LIFEAdditions.h"

@implementation NSString (LIFEAdditions)

/*
 * This is from here: http://stackoverflow.com/questions/18744447/autolayout-rtl-uilabel-text-alignment
 */
- (NSTextAlignment)life_naturalTextAligment {
    if (self.length == 0)
        return NSTextAlignmentNatural;
    NSArray *tagschemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeLanguage, nil];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagschemes options:0];
    [tagger setString:self];
    NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
    return LIFENSTextAlignmentForLanguage(language);
}

LIFE_CATEGORY_METHOD_IMPL(NSString);

@end

NSTextAlignment LIFENSTextAlignmentForLanguage(NSString *language) {
    if (language == nil) {
        return NSTextAlignmentLeft;
    }
    
    if ([language rangeOfString:@"he"].location != NSNotFound || [language rangeOfString:@"ar"].location != NSNotFound) {
        return NSTextAlignmentRight;
    } else {
        return NSTextAlignmentLeft;
    }
}

NSTextAlignment LIFENSTextAlignmentForTextFieldOrTextView(UIResponder *textFieldOrTextView) {
    NSString *language = textFieldOrTextView.textInputMode.primaryLanguage;
    return LIFENSTextAlignmentForLanguage(language);
}

void LIFEFixRTLForTextViewOrTextField(UIResponder *textViewOrTextField) {
    if ([textViewOrTextField isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)textViewOrTextField;
        NSString *newText = textField.text;
        
        if (newText.length > 0) {
            textField.textAlignment = newText.life_naturalTextAligment;
        }
    } else if ([textViewOrTextField isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)textViewOrTextField;
        NSString *newText = textView.text;
        
        if (newText.length > 0) {
            textView.textAlignment = newText.life_naturalTextAligment;
        }
    }
}

LIFE_CATEGORY_FUNCTION_IMPL(NSString);
