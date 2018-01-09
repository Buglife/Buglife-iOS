//
//  LIFEAttribute.h
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

#import <Foundation/Foundation.h>

/**
 @warning These map to enums in the Buglife backend API!
 */
typedef NS_ENUM(NSUInteger, LIFEAttributeValueType) {
    LIFEAttributeValueTypeString = 0,
    LIFEAttributeValueTypeInt = 1,
    LIFEAttributeValueTypeFloat = 2,
    LIFEAttributeValueTypeBool = 3
};

typedef NS_OPTIONS(NSUInteger, LIFEAttributeFlags) {
    LIFEAttributeFlagCustom   = 1 << 1, // The new default for dev-set attributes
    LIFEAttributeFlagSystem   = 1 << 2, // The new default for Buglife-gathered attributes
    LIFEAttributeFlagPublic   = 1 << 3, // Set this to show this attribute in public when not logged in (not supported yet)
    LIFEAttributeFlagInternal = 1 << 4, // This is for Buglife metrics only. Do not use.
};

@class LIFEAttribute;

typedef NSDictionary<NSString *, LIFEAttribute *> LIFEAttributes;
typedef NSMutableDictionary<NSString *, LIFEAttribute *> LIFEMutableAttributes;

@interface LIFEAttribute : NSObject <NSCoding>

@property (nonatomic, readonly) LIFEAttributeValueType valueType;
@property (nonatomic, readonly) LIFEAttributeFlags flags;

+ (instancetype)attributeWithBool:(BOOL)boolValue flags:(LIFEAttributeFlags)flags;
+ (instancetype)attributeWithString:(NSString *)stringValue flags:(LIFEAttributeFlags)flags;

- (instancetype)initWithValueType:(LIFEAttributeValueType)valueType value:(NSObject *)value flags:(LIFEAttributeFlags)flags;

- (NSString *)stringValue;

- (NSDictionary *)JSONDictionary;

@end
