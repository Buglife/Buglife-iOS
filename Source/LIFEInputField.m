//
//  LIFEInputField.m
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

#import "LIFEInputField+Protected.h"
#import "LIFELocalizedStringProvider.h"

@interface LIFEInputField ()

@property (nonatomic, nonnull) NSString *attributeName;

// Protected properties
@property (nonatomic, getter=isSystemAttribute) BOOL systemAttribute;

@end

@implementation LIFEInputField

- (instancetype)initWithAttributeName:(NSString *)attributeName
{
    self = [super init];
    if (self) {
        _attributeName = attributeName;
    }
    return self;
}

- (NSString *)title
{
    if (_title == nil) {
        _title = self.attributeName;
    }
    
    return _title;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    LIFEInputField *inputField = [[[self class] allocWithZone:zone] init];
    inputField.attributeName = self.attributeName;
    inputField.title = self.title;
    inputField.required = self.required;
    inputField.systemAttribute = self.systemAttribute;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    inputField.visible = self.visible;
#pragma clang diagnostic pop
    return inputField;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    LIFEInputField *other = (LIFEInputField *)object;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self.attributeName isEqualToString:other.attributeName] &&
        [self.title isEqualToString:other.title] &&
        (self.required == other.isRequired) &&
        (self.systemAttribute == other.systemAttribute) &&
        (self.visible == other.isVisible);
#pragma clang diagnostic pop
}

- (NSUInteger)hash
{
    return _attributeName.hash;
}

#pragma mark - Protected methods

- (BOOL)isUserEmailField
{
    return [self.attributeName isEqualToString:LIFEInputFieldUserEmailAttributeName];
}

- (BOOL)isSummaryField
{
    return [self.attributeName isEqualToString:LIFEInputFieldSummaryAttributeName];
}

+ (NSArray<LIFEInputField *> *)bugDetailInputFields
{
    LIFETextInputField *summaryInputField = [LIFETextInputField summaryInputField];
    summaryInputField.title = LIFELocalizedString(LIFEStringKey_SummaryInputFieldDetailedTitle);
    summaryInputField.placeholder = LIFELocalizedString(LIFEStringKey_SummaryInputFieldDetailedPlaceholder);
    summaryInputField.accessibilityHint = LIFELocalizedString(LIFEStringKey_SummaryInputFieldAccessibilityDetailedHint);
    
    LIFETextInputField *stepsToReproduce = [[LIFETextInputField alloc] initWithAttributeName:@"Steps to Reproduce"];
    stepsToReproduce.multiline = YES;
    stepsToReproduce.title = LIFELocalizedString(LIFEStringKey_StepsToReproduce);

    LIFETextInputField *expectedResults = [[LIFETextInputField alloc] initWithAttributeName:@"Expected Results"];
    expectedResults.multiline = YES;
    expectedResults.title = LIFELocalizedString(LIFEStringKey_ExpectedResults);
    expectedResults.placeholder = LIFELocalizedString(LIFEStringKey_ExpectedResultsPlaceholder);
    
    LIFETextInputField *actualResults = [[LIFETextInputField alloc] initWithAttributeName:@"Actual Results"];
    actualResults.multiline = YES;
    actualResults.title = LIFELocalizedString(LIFEStringKey_ActualResults);
    actualResults.placeholder = LIFELocalizedString(LIFEStringKey_ActualResultsPlaceholder);
    
    return @[summaryInputField, stepsToReproduce, expectedResults, actualResults];
}

#pragma mark - Debug description

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p; attributeName = \"%@\">", NSStringFromClass([self class]), self, self.attributeName];
}

@end
