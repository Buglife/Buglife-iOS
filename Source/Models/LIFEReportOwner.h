//
//  LIFEReportOwner.h
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


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LIFEReportOwnerType) {
    LIFEReportOwnerTypeAPIKey,
    LIFEReportOwnerTypeEmail
};


@interface LIFEReportOwner : NSObject

+ (nonnull instancetype)reportOwnerWithAPIKey:(nonnull NSString *)apiKey;
+ (nonnull instancetype)reportOwnerWithEmail:(nonnull NSString *)email;

@property (nonatomic, readonly) LIFEReportOwnerType ownerType;
@property (nonnull, nonatomic, readonly) NSString *ownerIdentifier;    // this is an API key, or email address, depending on the owner type

// god I wish I had Swift enums
- (void)switchCaseAPIKey:(nonnull void (^)( NSString * _Nonnull apiKey))apiKeyBlock email:(nonnull void (^)(NSString * _Nonnull email))emailBlock;

@end
