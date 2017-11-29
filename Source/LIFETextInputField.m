//
//  LIFETextInputField.m
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

#import "LIFETextInputField.h"
#import "LIFEMacros.h"
#import "LIFEInputField+Protected.h"

@implementation LIFETextInputField

#pragma mark - Class constructors for system fields

+ (nonnull instancetype)summaryInputField
{
    let inputField = [[LIFETextInputField alloc] initWithAttributeName:LIFEInputFieldSummaryAttributeName];
    inputField.multiline = YES;
    inputField.title = LIFELocalizedString(LIFEStringKey_SummaryInputFieldTitle);
    inputField.placeholder = LIFELocalizedString(LIFEStringKey_SummaryInputFieldPlaceholder);
    inputField.systemAttribute = YES;
    return inputField;
}

+ (nonnull instancetype)userEmailInputField
{
    let inputField = [[LIFETextInputField alloc] initWithAttributeName:LIFEInputFieldUserEmailAttributeName];
    inputField.title = LIFELocalizedString(LIFEStringKey_UserEmailInputFieldTitle);
    inputField.placeholder = LIFELocalizedString(LIFEStringKey_UserEmailInputFieldPlaceholder);
    inputField.systemAttribute = YES;
    return inputField;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    LIFETextInputField *inputField = [super copyWithZone:zone];
    inputField.multiline = self.multiline;
    inputField.placeholder = self.placeholder;
    return inputField;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    LIFETextInputField *other = (LIFETextInputField *)object;
    
    return ([super isEqual:other]) && (self.multiline == other.multiline) && (self.placeholder == other.placeholder);
}

@end
