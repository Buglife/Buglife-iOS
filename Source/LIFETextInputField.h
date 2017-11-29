//
//  LIFETextInputField.h
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
 * Represents a single- or multi-line text input field in the Buglife bug reporter interface.
 */
@interface LIFETextInputField : LIFEInputField

/**
 * The placeholder text displayed by the text field when it is empty.
 */
@property (nonatomic, nullable, copy) NSString *placeholder;

/**
 * Returns YES if this is a multi-line text input field,
 * or NO if it is a single-line text input field.
 * The default value for this is NO.
 */
@property (nonatomic, getter=isMultiline) BOOL multiline;

/**
 * Returns the system-provided summary field (i.e. "What happened?").
 * When there are no custom input fields configured,
 * the bug reporter UI shows the summary field by default.
 */
+ (nonnull instancetype)summaryInputField;

/**
 * Returns a field for entering the user's email address.
 *
 * If an email is programmatically set using Buglife.setUserEmail(),
 * then that email will be shown by default for this field.
 *
 * If the user edits the value for this field, then the new value
 * will override whatever value may have been provided via `BuglifesetUserEmail()`,
 * and the new value will persist across application launches.
 */
+ (nonnull instancetype)userEmailInputField;

@end
