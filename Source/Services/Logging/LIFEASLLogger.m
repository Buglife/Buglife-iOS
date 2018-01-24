//
//  LIFEASLLogger.m
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


#import "LIFEASLLogger.h"
#import <asl.h>

const char* const kLIFEASLKeyLIFELog = "LIFELog";

const char* const kLIFEASLLIFELogValue = "1";

static LIFEASLLogger *sharedInstance;

@interface LIFEASLLogger () {
    aslclient _client;
}

@end


@implementation LIFEASLLogger

+ (instancetype)sharedInstance {
    static dispatch_once_t LIFEASLLoggerOnceToken;
    
    dispatch_once(&LIFEASLLoggerOnceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (sharedInstance != nil) {
        return nil;
    }
    
    if ((self = [super init])) {
        // A default asl client is provided for the main thread,
        // but background threads need to create their own client.
        
        _client = asl_open(NULL, "com.apple.console", 0);
    }
    
    return self;
}

- (void)logMessage:(LIFELogMessage *)logMessage {
    // Skip captured log messages
    if ([logMessage->_fileName isEqualToString:@"LIFEASLLogCapture"]) {
        return;
    }
    
    NSString * message = _logFormatter ? [_logFormatter formatLogMessage:logMessage] : logMessage->_message;
    
    if (message != nil) {
        const char *msg = [message UTF8String];
        
        size_t aslLogLevel;
        switch (logMessage->_flag) {
                // Note: By default ASL will filter anything above level 5 (Notice).
                // So our mappings shouldn't go above that level.
            case LIFELogFlagError     : aslLogLevel = ASL_LEVEL_CRIT;     break;
            case LIFELogFlagWarning   : aslLogLevel = ASL_LEVEL_ERR;      break;
            case LIFELogFlagInfo      : aslLogLevel = ASL_LEVEL_WARNING;  break; // Regular NSLog's level
            case LIFELogFlagDebug     :
            case LIFELogFlagVerbose   :
            default                 : aslLogLevel = ASL_LEVEL_NOTICE;   break;
        }
        
        static char const *const level_strings[] = { "0", "1", "2", "3", "4", "5", "6", "7" };
        
        // NSLog uses the current euid to set the ASL_KEY_READ_UID.
        uid_t const readUID = geteuid();
        
        char readUIDString[16];
#ifndef NS_BLOCK_ASSERTIONS
        int l = snprintf(readUIDString, sizeof(readUIDString), "%d", readUID);
#else
        snprintf(readUIDString, sizeof(readUIDString), "%d", readUID);
#endif
        
        NSAssert(l < sizeof(readUIDString),
                 @"Formatted euid is too long.");
        NSAssert(aslLogLevel < (sizeof(level_strings) / sizeof(level_strings[0])),
                 @"Unhandled ASL log level.");
        
        aslmsg m = asl_new(ASL_TYPE_MSG);
        if (m != NULL) {
            if (asl_set(m, ASL_KEY_LEVEL, level_strings[aslLogLevel]) == 0 &&
                asl_set(m, ASL_KEY_MSG, msg) == 0 &&
                asl_set(m, ASL_KEY_READ_UID, readUIDString) == 0 &&
                asl_set(m, kLIFEASLKeyLIFELog, kLIFEASLLIFELogValue) == 0) {
                asl_send(_client, m);
            }
            asl_free(m);
        }
        //TODO handle asl_* failures non-silently?
    }
}

- (NSString *)loggerName {
    return @"cocoa.lumberjack.aslLogger";
}

@end
