//
//  LIFELogger.h
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


#import <Foundation/Foundation.h>
#import "LIFELog.h"

@interface LIFELogger : NSObject

+ (nonnull instancetype)sharedLogger;

// The only default whitelisted context is '0'
- (void)addToWhitelist:(NSInteger)loggingContext;
- (void)removeFromWhitelist:(NSInteger)loggingContext;

- (void)log:(BOOL)asynchronous
      level:(LIFELogLevel)level
       file:(nonnull const char *)file
   function:(nonnull const char *)function
       line:(NSUInteger)line
    context:(NSInteger)context
     format:(nonnull NSString *)format, ...  NS_FORMAT_FUNCTION(7,8);

+ (nullable NSString *)debugDescriptionForObject:(nullable NSObject *)object;

@end

#define LIFE_LOG_MACRO(isAsynchronous, lvl, ctx, fnct, frmt, ...)    \
    [[LIFELogger sharedLogger] log: isAsynchronous              \
                             level: lvl                         \
                              file: __FILE__                    \
                          function: fnct                        \
                              line: __LINE__                    \
                           context: ctx                         \
                            format: (frmt), ## __VA_ARGS__]

#define LIFELoggerContextInternalDebugMode 88
#define LIFELogIntDebug(frmt, ...)      LIFE_LOG_MACRO(YES, LIFELogLevelDebug, LIFELoggerContextInternalDebugMode, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define LIFELogIntInfo(frmt, ...)       LIFE_LOG_MACRO(YES, LIFELogLevelInfo,  LIFELoggerContextInternalDebugMode, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define LIFELogIntError(frmt, ...)      LIFE_LOG_MACRO(NO,  LIFELogLevelError, LIFELoggerContextInternalDebugMode, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define LIFEDebugDescription(obj)   [LIFELogger debugDescriptionForObject:obj]
