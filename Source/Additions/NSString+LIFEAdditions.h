//
//  NSString+LIFEAdditions.h
//  Pods
//
//  Created by David Schukin on 12/12/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LIFECategories.h"

@interface NSString (LIFEAdditions)

- (NSTextAlignment)life_naturalTextAligment;

@end

NSTextAlignment LIFENSTextAlignmentForLanguage(NSString *__nullable language);
NSTextAlignment LIFENSTextAlignmentForTextFieldOrTextView(UIResponder *__nullable textFieldOrTextView);
// This should be called from textViewDidChange: methods
void LIFEFixRTLForTextViewOrTextField(UIResponder *__nonnull textViewOrTextField);
LIFE_CATEGORY_FUNCTION_DECL(NSString);
