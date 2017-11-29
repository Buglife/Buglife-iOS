//
//  LIFELogFacility.m
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

#import "LIFELogFacility.h"
#import "LIFEMacros.h"
#import <asl.h>
#import <UIKit/UIKit.h>

static const NSUInteger kConsoleMaxLines = 1000;

@interface LIFELogFacilityMessage : NSObject

@property (nonatomic) NSString *message;
@property (nonatomic) NSTimeInterval timestamp;

@end

@interface LIFELogFacility ()

@property (nonatomic) NSMutableSet *collectedASLMessageIDs;
@property (nonatomic) NSMutableArray<LIFELogFacilityMessage *> *consoleMessages;
@property (nonatomic) dispatch_queue_t logQueue;

@end

@implementation LIFELogFacility

- (instancetype)init
{
    self = [super init];
    if (self) {
        _collectedASLMessageIDs = [[NSMutableSet alloc] init];
        _consoleMessages = [[NSMutableArray alloc] init];
        _logQueue = dispatch_queue_create("com.buglife.LIFELogFacility.logQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)fetchFormattedLogsToQueue:(dispatch_queue_t)returnQueue completion:(void (^)(NSString *))completionHandler
{
    __weak typeof(self) weakSelf = self;

    dispatch_async(self.logQueue, ^{
        NSString *formattedLogs = [weakSelf _formattedLogs];
        
        dispatch_async(returnQueue, ^{
            completionHandler(formattedLogs);
        });
    });
}

- (NSString *)formattedLogs
{
    NSAssert([NSThread isMainThread] == NO, @"Don't call this on the main thread!");
    return [self _formattedLogs];
}

- (NSString *)_formattedLogs
{
    BOOL updated = [self _updateFromASL];
    
    if (!updated) {
        LIFELogIntError(@"Couldn't update from ASL!");
    }

#if !LIFE_DEMO_MODE
    NSParameterAssert(updated);
#endif
    
    NSMutableString *mutableLogString = [[NSMutableString alloc] init];
    
    for (LIFELogFacilityMessage *logMessage in self.consoleMessages) {
        [mutableLogString appendFormat:@"%f %@\n", logMessage.timestamp, logMessage.message];
    }
    
    return [[NSString alloc] initWithString:mutableLogString];
}

// assumed to always be in logQueue
- (BOOL)_updateFromASL
{
    pid_t myPID = getpid();
    
    // thanks http://www.cocoanetics.com/2011/03/accessing-the-ios-system-log/
    
    aslmsg q, m;
    q = asl_new(ASL_TYPE_QUERY);
    aslresponse r = asl_search(NULL, q);
    BOOL foundNewEntries = NO;
    
    while ( (m = SystemSafeASLNext(r)) ) {
        if (myPID != atol(asl_get(m, ASL_KEY_PID))) continue;
        
        // dupe checking
        NSNumber *msgID = @( atoll(asl_get(m, ASL_KEY_MSG_ID)) );
        if ([_collectedASLMessageIDs containsObject:msgID]) continue;
        [_collectedASLMessageIDs addObject:msgID];
        foundNewEntries = YES;
        
        NSTimeInterval msgTime = (NSTimeInterval) atol(asl_get(m, ASL_KEY_TIME)) + ((NSTimeInterval) atol(asl_get(m, ASL_KEY_TIME_NSEC)) / 1000000000.0);
        
        const char *msg = asl_get(m, ASL_KEY_MSG);
        if (msg == NULL) { continue; }
        [self addLogMessage:[NSString stringWithUTF8String:msg] timestamp:msgTime];
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
        asl_release(r);
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // The deprecation attribute incorrectly states that the replacement method, asl_release()
        // is available in __IPHONE_7_0; asl_release() first appears in __IPHONE_8_0.
        // This would require both a compile and runtime check to properly implement the new method
        // while the minimum deployment target for this project remains iOS 7.0.
        aslresponse_free(r);
#pragma clang diagnostic pop
    }
    asl_free(q);
    
    return foundNewEntries;
}

// Because aslresponse_next is now deprecated.
asl_object_t SystemSafeASLNext(asl_object_t r) {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
        return asl_next(r);
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // The deprecation attribute incorrectly states that the replacement method, asl_next()
    // is available in __IPHONE_7_0; asl_next() first appears in __IPHONE_8_0.
    // This would require both a compile and runtime check to properly implement the new method
    // while the minimum deployment target for this project remains iOS 7.0.
    return aslresponse_next(r);
#pragma clang diagnostic pop
}

// assumed to always be in logQueue
- (void)addLogMessage:(NSString *)message timestamp:(NSTimeInterval)timestamp
{
    LIFELogFacilityMessage *msg = [LIFELogFacilityMessage new];
    msg.message = message;
    msg.timestamp = timestamp;
    [self.consoleMessages addObject:msg];
    
    // once the log has exceeded the length limit by 25%, prune it to the length limit
    if (self.consoleMessages.count > kConsoleMaxLines * 1.25) {
        [self.consoleMessages removeObjectsInRange:NSMakeRange(0, self.consoleMessages.count - kConsoleMaxLines)];
    }
}

@end

@implementation LIFELogFacilityMessage

@end
