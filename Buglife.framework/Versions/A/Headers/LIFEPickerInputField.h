//
//  LIFEPickerInputField.h
//  Buglife
//
//  Copyright (c) 2017 Buglife, Inc. All rights reserved.
//

#import "LIFEInputField.h"

/**
 * Represents a `picker` style input field in the Buglife bug reporter interface,
 * that allows the user to select a single value from an array of options.
 */
@interface LIFEPickerInputField : LIFEInputField

/**
 * Sets the options for the picker.
 * To set the `default` option, call `Buglife.setStringValue(_:forAttribute:)` with
 * an attribute name equal to the picker attribute name, and an attribute value
 * equal to one of the picker options.
 */
- (void)setOptions:(nonnull NSArray<NSString *> *)options;

@end
