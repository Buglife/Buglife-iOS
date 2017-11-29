//
//  LIFEAppInfoProvider.m
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

#import "LIFEAppInfoProvider.h"
#import "LIFEAppInfo.h"
#import "LIFEMacros.h"

@interface LIFEAppInfoProvider ()

@property (nonatomic) dispatch_queue_t workQueue;

@end

@implementation LIFEAppInfoProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        _workQueue = dispatch_queue_create("com.buglife.LIFEAppInfoProvider.workQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Public methods

- (void)asyncFetchAppInfoToQueue:(dispatch_queue_t)completionQueue completion:(void (^)(LIFEAppInfo *))completionHandler
{
    __weak typeof(self) weakSelf = self;

    dispatch_async(_workQueue, ^{
        __strong LIFEAppInfoProvider *strongSelf = weakSelf;
        
        if (strongSelf) {
            LIFEAppInfo *appInfo = [strongSelf _appInfo];
            
            dispatch_async(completionQueue, ^{
                completionHandler(appInfo);
            });
        } else {
            NSAssert(NO, @"weak ref zero'd out before strongifying");
            LIFELogIntError(@"Error getting app info (error code 136)"); // arbitrary error code. TODO: keep track of these somewhere
            dispatch_async(completionQueue, ^{
                completionHandler(nil);
            });
        }
    });
}

- (LIFEAppInfo *)syncFetchAppInfo
{
    return [self _appInfo];
}

#pragma mark - Private methods

- (LIFEAppInfo *)_appInfo
{
    NSParameterAssert(![NSThread isMainThread]);
    LIFEAppInfo *appInfo = [[LIFEAppInfo alloc] init];
    NSBundle *bundle = [NSBundle mainBundle];
    
    appInfo.bundleShortVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appInfo.bundleVersion = [bundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    appInfo.bundleIdentifier = [bundle bundleIdentifier];
    appInfo.bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    return appInfo;
}

@end
