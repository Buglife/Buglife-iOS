//
//  LIFEPickerInputField.h
//  Buglife
//
//  Copyright (c) 2017 Buglife, Inc. All rights reserved.
//

#import "LIFEInputField.h"

@interface LIFEPickerInputField : LIFEInputField

- (nonnull instancetype)initWithAttributeName:(nonnull NSString *)attributeName;
- (void)setOptions:(nonnull NSArray<NSString *> *)options;

@end
