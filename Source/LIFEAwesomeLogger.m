//
//  LIFEBuglifeLogger.m
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
#import "LIFETTYLogger.h"
#import "LIFELog.h"
#import "LIFEFileLogger.h"
#import "LIFEJSONLogFileFormatter.h"
#import "LIFEContextAwareLogFormatter.h"
#import "LIFENotificationLogger.h"
#import "LIFECompatibilityUtils.h"
#import "UIDevice+LIFEAdditions.h"

// The maximum individual filesize is 25kb;
// since the maximum number of log files is 5,
// this puts the maximum total log filesize at 125kb
static const unsigned long long kLogMaximumFileSize = 25 * 1000;
static const BOOL kConsoleLoggingEnabledDefault = YES;

@interface LIFEAwesomeLogger ()

@property (nonatomic) LIFELogLevel logLevel;
@property (nonatomic) LIFEFileLogger *fileLogger;
@property (nonatomic) dispatch_queue_t workQueue;
@property (nonatomic) LIFENotificationLogger *notificationLogger;

// This is different from the corresponding header property, which can be
// accessed from any thread. This property must only be accessed from `workQueue`
@property (nonatomic) BOOL consoleLoggingEnabledImpl;

@end

// Equivalent of CocoaLumberjack's DDLog
@protocol LIFEDDLogMessage <NSObject>

- (NSString *)message;
- (LIFELogFlag)flag;
- (NSString *)file;
- (NSString *)function;
- (NSUInteger)line;

@end

@implementation LIFEAwesomeLogger

@dynamic consoleLoggingEnabled;

#pragma mark - Initialization

+ (instancetype)sharedLogger
{
    static LIFEAwesomeLogger *sSharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[self alloc] init];
    });
    return sSharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _life_privateInit];
    }
    return self;
}

- (void)_life_privateInit
{
    _logLevel = LIFELogLevelAll;
    
    LIFEJSONLogFileFormatter *logFormatter = [[LIFEJSONLogFileFormatter alloc] init];
    _fileLogger = [[LIFEFileLogger alloc] initWithLogFormatter:logFormatter];
    _fileLogger.maximumFileSize = kLogMaximumFileSize;
    _fileLogger.rollingFrequency = 0;
    
    _workQueue = dispatch_queue_create("com.buglife.LIFEBuglifeLogger.workQueue", DISPATCH_QUEUE_SERIAL);
    
    self.notificationLogger = [[LIFENotificationLogger alloc] init];
    [self.notificationLogger beginLoggingNotifications];

    // Wrap this in a dispatch once;
    // API consumers *should* use the shared singleton, but in case
    // they don't, we still want to create our loggers just once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [LIFELogImpl addLogger:_fileLogger];
        
        [LIFETTYLogger sharedInstance].logFormatter = [[LIFEContextAwareLogFormatter alloc] init];
        
        self.consoleLoggingEnabledImpl = kConsoleLoggingEnabledDefault;
    });
}

#pragma mark - Public methods

- (void)log:(BOOL)asynchronous
       type:(LIFEAwesomeLogType)type
       file:(nonnull const char *)file
   function:(nonnull const char *)function
       line:(NSUInteger)line
     format:(nonnull NSString *)format, ...
{
    va_list args;
    
    if (format) {
        va_start(args, format);
        
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        [self _log:asynchronous message:message type:type file:file function:function line:line];

        va_end(args);
    }
}

- (void)log:(BOOL)asynchronous
       type:(LIFEAwesomeLogType)type
       file:(nonnull NSString *)file
   function:(nonnull NSString *)function
       line:(NSUInteger)line
    message:(nonnull NSString *)message
{
    [self _log:asynchronous message:message type:type file:[file cStringUsingEncoding:NSASCIIStringEncoding] function:[function cStringUsingEncoding:NSASCIIStringEncoding] line:line];
}

#pragma mark - Protected methods

- (void)asyncFlushLogsAndGetArchivedLogDataWithCompletion:(void (^)(NSData *archivedLogData))completion
{
    [LIFELogImpl flushLog];

    __weak typeof(self) weakSelf = self;
    
    [self.fileLogger rollLogFileToQueue:self.workQueue completionBlock:^{
        __strong LIFEAwesomeLogger *strongSelf = weakSelf;
        
        if (strongSelf) {
            NSData *archivedLogData = [strongSelf _archivedLogData];
            completion(archivedLogData);
        }
    }];
}

#pragma mark - DDLogger (CocoaLumberjack)

- (void)logMessage:(NSObject<LIFEDDLogMessage> *)ddLogMessage
{
    LIFELogMessage *logMessage = [[LIFELogMessage alloc] initWithMessage:ddLogMessage.message
                                                                   level:_logLevel
                                                                    flag:ddLogMessage.flag
                                                                 context:LIFELogContextCocoaLumberjack
                                                                    file:ddLogMessage.file
                                                                function:ddLogMessage.function
                                                                    line:ddLogMessage.line
                                                                     tag:nil
                                                                 options:(LIFELogMessageOptions)0
                                                               timestamp:nil];
    BOOL async = (ddLogMessage.flag != LIFELogFlagError);
    [LIFELogImpl log:async message:logMessage];
}

- (id)logFormatter
{
    return nil;
}

- (void)setLogFormatter:(id)logFormatter
{
}

#pragma mark - Private methods

- (nullable NSData *)_archivedLogData
{
    BOOL logsEmpty = YES; // This will remain YES & return nil if the user never actually used AwesomeLogs
    id<LIFELogFileManager> logFileManager = self.fileLogger.logFileManager;
    
    NSArray<LIFELogFileInfo *> *logFileInfos = [logFileManager sortedLogFileInfos];
    
    // Reverse the order; otherwise, the ordering gets screwed up once
    // we stich files together
    logFileInfos = [[logFileInfos reverseObjectEnumerator] allObjects];
    
    NSMutableData *mutableLogData = [[NSMutableData alloc] init];
    
    // Since this is supposed to represent a JSON array, prepend the
    // data with an opening array string
    [mutableLogData appendData:[@"[" dataUsingEncoding:NSUTF8StringEncoding]];
    
    for (LIFELogFileInfo *logFileInfo in logFileInfos) {
        NSAssert(logFileInfo.isArchived, @"Logs should already be archived at this point");
        NSError *error;
        NSData *logData = [[NSData alloc] initWithContentsOfFile:logFileInfo.filePath options:0 error:&error];
        
        if (logData.length > 0) {
            [mutableLogData appendData:logData];
            logsEmpty = NO;
        } else {
            NSAssert(NO, @"Error getting log data: %@", error);
        }
    }
    
    if (logsEmpty) {
        return nil;
    }
    
    // Close the JSON array.
    // We close it with one last empty hash, since prior to the end is
    // the last log message which is appended with a comma
    [mutableLogData appendData:[@"{\"end\":\"true\"}]" dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [[NSData alloc] initWithData:mutableLogData];
}

- (void)_log:(BOOL)asynchronous
     message:(NSString *)message
        type:(LIFEAwesomeLogType)type
        file:(const char *)file
    function:(const char *)function
        line:(NSUInteger)line
{
    LIFELogFlag flag = (LIFELogFlag)type;
    LIFELogMessage *logMessage = [[LIFELogMessage alloc] initWithMessage:message
                                                               level:_logLevel
                                                                flag:flag
                                                             context:0
                                                                file:[NSString stringWithFormat:@"%s", file]
                                                            function:[NSString stringWithFormat:@"%s", function]
                                                                line:line
                                                                 tag:nil
                                                             options:(LIFELogMessageOptions)0
                                                           timestamp:nil];

    [LIFELogImpl log:asynchronous message:logMessage];
}

- (void)_logDebugMessage:(NSString *)message context:(NSInteger)context
{
    LIFELogMessage *logMessage = [[LIFELogMessage alloc] initWithMessage:message
                                                                   level:_logLevel
                                                                    flag:LIFELogFlagDebug
                                                                 context:context
                                                                    file:nil
                                                                function:nil
                                                                    line:0
                                                                     tag:nil
                                                                 options:(LIFELogMessageOptions)0
                                                               timestamp:nil];
    
    [LIFELogImpl log:YES message:logMessage];
}

#pragma mark - Console Logging

- (BOOL)isConsoleLoggingEnabled
{
    __block BOOL enabled = kConsoleLoggingEnabledDefault;
    __weak typeof(self) weakSelf = self;
    
    dispatch_sync(_workQueue, ^{
        __strong LIFEAwesomeLogger *strongSelf = weakSelf;
        
        if (strongSelf) {
            enabled = strongSelf.consoleLoggingEnabledImpl;
        }
    });
    
    return enabled;
}

- (void)setConsoleLoggingEnabled:(BOOL)consoleLoggingEnabled
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(_workQueue, ^{
        __strong LIFEAwesomeLogger *strongSelf = weakSelf;
        
        if (strongSelf) {
            strongSelf.consoleLoggingEnabledImpl = consoleLoggingEnabled;
        }
    });
}

- (void)setConsoleLoggingEnabledImpl:(BOOL)consoleLoggingEnabledImpl
{
    if (consoleLoggingEnabledImpl != _consoleLoggingEnabledImpl) {
        _consoleLoggingEnabledImpl = consoleLoggingEnabledImpl;
        
        if (consoleLoggingEnabledImpl) {
            [LIFELogImpl addLogger:[LIFETTYLogger sharedInstance]];
        } else {
            [LIFELogImpl removeLogger:[LIFETTYLogger sharedInstance]];
        }
    }
}

@end
