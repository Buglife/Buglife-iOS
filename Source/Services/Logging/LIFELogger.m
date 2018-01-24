//
//  LIFELogger.m
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


#import "LIFELogger.h"

@interface LIFELogger ()

@property (nonatomic) dispatch_queue_t loggingQueue;
@property (nonatomic) NSMutableSet<NSNumber *> *contextSet; // should only be accessed / mutated on loggingQueue

@end

@implementation LIFELogger

#pragma mark - Initialization

+ (instancetype)sharedLogger
{
    static LIFELogger *sSharedLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedLogger = [[self alloc] init];
    });
    return sSharedLogger;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loggingQueue = dispatch_queue_create("com.buglife.LIFELogger.loggingQueue", DISPATCH_QUEUE_SERIAL);
        _contextSet = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark - Public methods

- (void)addToWhitelist:(NSInteger)loggingContext
{
    dispatch_sync(_loggingQueue, ^{
        [self.contextSet addObject:@(loggingContext)];
    });
}

- (void)removeFromWhitelist:(NSInteger)loggingContext
{
    dispatch_sync(_loggingQueue, ^{
        [self.contextSet removeObject:@(loggingContext)];
    });
}

- (void)log:(BOOL)asynchronous
      level:(LIFELogLevel)level
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
    context:(NSInteger)context
     format:(NSString *)format, ...
{
    va_list args;
    
    if (format) {
        va_start(args, format);
        
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        [self _log:asynchronous level:level file:file function:function line:line context:context message:message];
        
        va_end(args);
    }
}

+ (NSString *)debugDescriptionForObject:(NSObject *)object
{
    if (object) {
        NSString *objectClass = NSStringFromClass([object class]);
        return [NSString stringWithFormat:@"<%@: %p>", objectClass, object];
    } else {
        return nil;
    }
}

#pragma mark - Private methods

- (void)_log:(BOOL)asynchronous
       level:(LIFELogLevel)level
        file:(const char *)file
    function:(const char *)function
        line:(NSUInteger)line
     context:(NSInteger)context
     message:(NSString *)message
{
    dispatch_block_t logBlock = ^{
        BOOL shouldLogToConsole = NO;
        
        if (context == 0) {
            shouldLogToConsole = YES;
        } else {
            shouldLogToConsole = [self.contextSet containsObject:@(context)];
        }
        
        //HACK 1/18/18: disable Debug Mode logging. 
        if (shouldLogToConsole && context != LIFELoggerContextInternalDebugMode) {
            NSLog(@"%@", message);
        }
    };

    if (asynchronous) {
        dispatch_async(_loggingQueue, logBlock);
    } else {
        dispatch_sync(_loggingQueue, logBlock);
    }
}

@end
