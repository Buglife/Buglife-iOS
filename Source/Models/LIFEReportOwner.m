//
//  LIFEReportOwner.m
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


#import "LIFEReportOwner.h"

@interface LIFEReportOwner ()

@property (nonatomic) LIFEReportOwnerType ownerType;
@property (nonatomic) NSString *ownerIdentifier;    // this is an API key, or email address, depending on the owner type

@end

@implementation LIFEReportOwner

+ (instancetype)reportOwnerWithAPIKey:(NSString *)apiKey
{
    return [self _reportOwnerWithType:LIFEReportOwnerTypeAPIKey identifier:apiKey];
}

+ (instancetype)reportOwnerWithEmail:(NSString *)email
{
    return [self _reportOwnerWithType:LIFEReportOwnerTypeEmail identifier:email];
}

+ (instancetype)_reportOwnerWithType:(LIFEReportOwnerType)type identifier:(NSString *)identifier
{
    LIFEReportOwner *reportOwner = [[LIFEReportOwner alloc] init];
    reportOwner.ownerType = type;
    reportOwner.ownerIdentifier = identifier;
    return reportOwner;
}

- (void)switchCaseAPIKey:(void (^)(NSString *apiKey))apiKeyBlock email:(void (^)(NSString *email))emailBlock
{
    switch (_ownerType) {
        case LIFEReportOwnerTypeAPIKey:
            apiKeyBlock(self.ownerIdentifier);
            break;
        case LIFEReportOwnerTypeEmail:
            emailBlock(self.ownerIdentifier);
            break;
    }
}

@end
