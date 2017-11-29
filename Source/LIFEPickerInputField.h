//
//  LIFEPickerInputField.h
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
