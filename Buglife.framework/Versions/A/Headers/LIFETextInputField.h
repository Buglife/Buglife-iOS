//
//  LIFETextInputField.h
//  Buglife
//
//  Copyright (c) 2017 Buglife, Inc. All rights reserved.
//

#import "LIFEInputField.h"

@interface LIFETextInputField : LIFEInputField

@property (nonatomic, nullable, copy) NSString *placeholder;
@property (nonatomic, getter=isMultiline) BOOL multiline;

+ (nonnull instancetype)summaryInputField;
+ (nonnull instancetype)userEmailInputField;

@end
