//
//  LIFEContextAwareLogFormatter.m
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


#import "LIFEContextAwareLogFormatter.h"

@implementation LIFEContextAwareLogFormatter
{
    NSDictionary *_prefixes;
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _prefixes = @{
                      @(LIFELogFlagError) : @"‼️ ",
                      @(LIFELogFlagWarning) : @"❗ "
                      };
    }
    return self;
}

#pragma mark - LIFELogFormatter

- (NSString *)formatLogMessage:(LIFELogMessage *)logMessage
{
    if ([self _shouldLogToConsoleAndASL:logMessage]) {
        NSString *message = logMessage.message;
        NSString *prefix = _prefixes[@(logMessage->_flag)];
        
        if (prefix) {
            message = [prefix stringByAppendingString:message];
        }
        
        return message;
    } else {
        return nil;
    }
}

- (BOOL)_shouldLogToConsoleAndASL:(LIFELogMessage *)logMessage
{
    if (logMessage.context == LIFELogContextSDKInternal) {
        return NO;
    } else if (logMessage.context == LIFELogContextNotification) {
        return NO;
    } else if (logMessage.context == LIFELogContextUserEvent) {
        return NO;
    } else if (logMessage.context == LIFELogContextCocoaLumberjack) {
        // If they're using CocoaLumberjack, then they're probably
        // doing logging to the console + ASL themselves
        return NO;
    }
    
    return YES;
}

@end
