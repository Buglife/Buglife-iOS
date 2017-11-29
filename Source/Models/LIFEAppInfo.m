//
//  LIFEAppInfo.m
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

#import "LIFEAppInfo.h"
#import "LIFEMacros.h"
#import "NSMutableDictionary+LIFEAdditions.h"

@implementation LIFEAppInfo

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        for (NSString *key in [[self class] _objectPropertyKeys]) {
            id value = [coder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    for (NSString *key in [[self class] _objectPropertyKeys]) {
        id value = [self valueForKey:key];
        [coder encodeObject:value forKey:key];
    }
}

+ (NSArray<NSString *> *)_objectPropertyKeys
{
    return @[LIFE_STRING_FROM_SELECTOR_NAMED(bundleShortVersion),
             LIFE_STRING_FROM_SELECTOR_NAMED(bundleVersion),
             LIFE_STRING_FROM_SELECTOR_NAMED(bundleIdentifier),
             LIFE_STRING_FROM_SELECTOR_NAMED(bundleName)];
}

- (NSDictionary *)JSONDictionary
{
    LIFEAppInfo *appInfo = self;
    NSMutableDictionary *appDict = @{}.mutableCopy;

    [LIFENSMutableDictionaryify(appDict) life_safeSetObject:appInfo.bundleIdentifier forKey:@"bundle_identifier"];
    [LIFENSMutableDictionaryify(appDict) life_safeSetObject:appInfo.bundleShortVersion forKey:@"bundle_short_version"];
    [LIFENSMutableDictionaryify(appDict) life_safeSetObject:appInfo.bundleVersion forKey:@"bundle_version"];
    [LIFENSMutableDictionaryify(appDict) life_safeSetObject:appInfo.bundleName forKey:@"bundle_name"];
    
    return [NSDictionary dictionaryWithDictionary:appDict];
}

@end
