//
//  LIFEDataProvider.h
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

#import <Foundation/Foundation.h>
#import "Buglife.h"

typedef void (^LIFEDataProviderSubmitCompletion)(BOOL submitted);

@class LIFEReport;
@class LIFEReportOwner;

@interface LIFEDataProvider : NSObject

- (nonnull instancetype)initWithReportOwner:(nonnull LIFEReportOwner *)reportOwner SDKVersion:(nonnull NSString *)sdkVersion;
- (_Null_unspecified instancetype)init NS_UNAVAILABLE;
- (void)submitReport:(nonnull LIFEReport *)report withRetryPolicy:(LIFERetryPolicy)retryPolicy completion:(nullable LIFEDataProviderSubmitCompletion)completion;
- (void)flushPendingReportsAfterDelay:(NSTimeInterval)delay;
- (void)logClientEventWithName:(nonnull NSString *)eventName afterDelay:(NSTimeInterval)delay;
- (void)logClientEventWithName:(nonnull NSString *)eventName;

@end
