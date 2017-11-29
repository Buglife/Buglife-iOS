//
//  LIFEAttribute.m
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

#import "LIFEAttribute.h"
#import "NSMutableDictionary+LIFEAdditions.h"

@interface LIFEAttribute ()

@property (nonatomic) LIFEAttributeValueType valueType;
@property (nonatomic) NSObject *value;

@end

@implementation LIFEAttribute

- (instancetype)initWithValueType:(LIFEAttributeValueType)valueType value:(NSObject *)value
{
    self = [super init];
    if (self) {
        _valueType = valueType;
        _value = value;
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _valueType = [coder decodeIntegerForKey:NSStringFromSelector(@selector(valueType))];
        _value = [coder decodeObjectForKey:NSStringFromSelector(@selector(value))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:_valueType forKey:NSStringFromSelector(@selector(valueType))];
    [coder encodeObject:_value forKey:NSStringFromSelector(@selector(value))];
}

#pragma mark - Public methods

- (NSString *)stringValue
{
    if (_valueType == LIFEAttributeValueTypeString) {
        return (NSString *)_value;
    } else {
        return [_value description];
    }
}

#pragma mark - JSON serialization

- (NSDictionary *)JSONDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict life_safeSetObject:@(_valueType) forKey:@"attribute_type"];
    [dict life_safeSetObject:_value forKey:@"attribute_value"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
