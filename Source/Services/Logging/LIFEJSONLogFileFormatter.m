//
//  LIFEJSONLogFileFormatter.m
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


// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2016, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.


#import "LIFEJSONLogFileFormatter.h"
#import "NSMutableDictionary+LIFEAdditions.h"
#import "LIFEContextAwareLogFormatter.h"

@interface LIFEJSONLogFileFormatter ()

@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation LIFEJSONLogFileFormatter

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4]; // 10.4+ style
        [_dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    }
    return self;
}

#pragma mark - DDLogFormatter

- (NSString *)formatLogMessage:(LIFELogMessage *)logMessage
{
    NSTimeInterval millisecondsSince1970 = (1000 * [logMessage->_timestamp timeIntervalSince1970]);
    NSString *timestamp = [NSString stringWithFormat:@"%.0f", millisecondsSince1970];

    NSMutableDictionary *logDictionary =
    @{
      @"type" : @(logMessage->_flag),
      @"line" : @(logMessage->_line)
      }.mutableCopy;
    
    [logDictionary life_safeSetObject:logMessage->_message forKey:@"message"];
    [logDictionary life_safeSetObject:logMessage->_function forKey:@"function"];
    [logDictionary life_safeSetObject:timestamp forKey:@"timestamp"];
    
    if (logMessage.context != 0) {
        [logDictionary life_safeSetObject:@(logMessage.context) forKey:@"context"];
    }
    
    NSString *fileName = [logMessage->_file lastPathComponent];
    [logDictionary life_safeSetObject:fileName forKey:@"file_name"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:logDictionary options:0 error:&error];
    NSString *jsonString;
    
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return [jsonString stringByAppendingString:@","];
    } else {
        jsonString = [NSString stringWithFormat:@"{\"type\": %@, \"context\": %@, \"line\": %@, \"file_name\": \"%@\", \"timestamp\": \"%@\"}", @(LIFELogFlagError), @(LIFELogContextSDKInternal), @(logMessage->_line), fileName, timestamp];
    }

    return [jsonString stringByAppendingString:@","];
}

@end
