//
//  LIFENotificationLogger.m
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


#import "LIFENotificationLogger.h"
//#import "LIFEMacros.h"
#import "LIFEAwesomeLogger+Protected.h"
#import "LIFEContextAwareLogFormatter.h"
#import <UIKit/UIKit.h>

NSString * const LIFENotificationLoggerBuglifeInvoked = @"com.buglife.LIFENotificationLogger.BuglifeInvoked";
NSString * const LIFENotificationLoggerSendButtonTapped = @"com.buglife.LIFENotificationLogger.SendButtonTapped";

@implementation LIFENotificationLogger

- (void)beginLoggingNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSArray<NSNotificationName> *notificationNames = [[LIFENotificationLogger _notifications] allKeys];
    
    for (NSNotificationName notification in notificationNames) {
        [center addObserver:self selector:@selector(_didReceiveNotification:) name:notification object:nil];
    }
}

#pragma mark - Notification handlers

- (void)_didReceiveNotification:(NSNotification *)notifiation
{
    NSNotificationName name = notifiation.name;
    
    if (name) {
        NSNumber *notificationNumber = [LIFENotificationLogger _notifications][name];
        
        if (notificationNumber != nil) {
            NSString *message = [NSString stringWithFormat:@"%@", notificationNumber];
            [[LIFEAwesomeLogger sharedLogger] _logDebugMessage:message context:LIFELogContextNotification];
        } else {
            // hyper defensive programming
            NSParameterAssert(NO);
        }
    } else {
        NSParameterAssert(NO);
//        LIFELogIntError(@"Buglife error: Notification received with no name. Please report this error!");
    }
}

+ (NSDictionary<NSNotificationName, NSNumber *> *)_notifications
{
    static NSDictionary *notifications;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notifications = @{
                          UIApplicationDidEnterBackgroundNotification: @(1),
                          UIApplicationWillEnterForegroundNotification: @(2),
                          UIApplicationDidFinishLaunchingNotification: @(3),
                          UIApplicationDidBecomeActiveNotification: @(4),
                          UIApplicationWillResignActiveNotification: @(5),
                          UIApplicationDidReceiveMemoryWarningNotification: @(6),
                          UIApplicationWillTerminateNotification: @(7),
                          UIApplicationUserDidTakeScreenshotNotification: @(8),
                          LIFENotificationLoggerBuglifeInvoked: @(9),
                          LIFENotificationLoggerSendButtonTapped: @(10)
                          };
    });
    
    return notifications;
}

@end
