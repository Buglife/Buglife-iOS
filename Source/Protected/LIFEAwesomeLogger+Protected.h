//
//  LIFEBuglifeLogger+Protected.h
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

#import "LIFEAwesomeLogger.h"

@class LIFEFileLogger;

@interface LIFEAwesomeLogger (Protected)

@property (nonatomic, readonly) LIFEFileLogger *fileLogger;
@property (nonatomic, readonly) dispatch_queue_t workQueue;

- (void)asyncFlushLogsAndGetArchivedLogDataWithCompletion:(void (^)(NSData *archivedLogData))completion;

// Should be used for internal logging, where
// the source file / function / line are irrelevant
- (void)_logDebugMessage:(NSString *)message context:(NSInteger)context;

@end
