//
//  LIFEPickerInputField.m
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

#import "LIFEPickerInputField.h"
#import "LIFEInputField+Protected.h"

@interface LIFEPickerInputField ()

@property (nonatomic, nonnull) NSMutableArray<NSString *> *optionTitles;
@property (nonatomic, nonnull) NSMutableArray<NSString *> *optionValues;

@end

@implementation LIFEPickerInputField

- (instancetype)initWithAttributeName:(NSString *)attributeName
{
    self = [super initWithAttributeName:attributeName];
    if (self) {
        _optionTitles = [[NSMutableArray alloc] init];
        _optionValues = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setOptions:(NSArray<NSString *> *)options
{
    if (options == nil) {
        options = @[];
    }
    
    _optionTitles = [NSMutableArray arrayWithArray:options];
    _optionValues = [NSMutableArray arrayWithArray:options];
}

#pragma mark - Accessors

- (nonnull NSArray<NSString *> *)optionTitlesArray
{
    return [NSArray arrayWithArray:_optionTitles];
}

- (nonnull NSArray<NSString *> *)optionValuesArray
{
    return [NSArray arrayWithArray:_optionValues];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    LIFEPickerInputField *inputField = [super copyWithZone:zone];
    inputField.optionTitles = self.optionTitles;
    inputField.optionValues = self.optionValues;
    return inputField;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    LIFEPickerInputField *other = (LIFEPickerInputField *)object;
    
    return [super isEqual:other] &&
        [self.optionTitles isEqualToArray:other.optionTitles] &&
        [self.optionValues isEqualToArray:other.optionTitles];
}

@end
