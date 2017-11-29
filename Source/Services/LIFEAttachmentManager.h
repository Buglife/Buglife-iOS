//
//  LIFEAttachmentManager.h
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
#import "Buglife+Protected.h"

@class LIFEReportAttachmentImpl;

@interface LIFEAttachmentManager : NSObject

- (void)asyncOpenRequestsForDuration:(NSTimeInterval)duration expirationHandler:(nonnull void (^)(void))expirationHandler;
- (void)asyncCloseRequestsAndSettleAttachments;

- (void)asyncFlushSettledAttachmentsToQueue:(nonnull dispatch_queue_t)queue completion:(nonnull void (^)(NSArray<LIFEReportAttachmentImpl *> * _Nullable settledAttachments))completion;

// The public equivalent of this interface specifies non-null parameters,
// but we specify nullable here since we handle them internally, and Obj-C
// callers can always pass in null anyway
- (BOOL)syncAddAttachmentWithData:(nullable NSData *)attachmentData type:(nullable NSString *)attachmentType filename:(nullable NSString *)filename error:(NSError * _Nullable * _Nullable)error requestsClosedHandler:(nonnull void (^)(void))requestsClosedHandler;

// The public equivalent of this interface specifies non-null parameters,
// but we specify nullable here since we handle them internally, and Obj-C
// callers can always pass in null anyway
- (void)asyncAddAttachmentWithImage:(nullable UIImage *)image filename:(nullable NSString *)filename requestsClosedHandler:(nonnull void (^)(void))requestsClosedHandler;

#pragma mark - TESTING

// Exposed for testing purposes only!!!
@property (nonatomic, readonly, nonnull) dispatch_queue_t attachmentQueue;

@end

LIFEAttachmentType * __nonnull LIFEFineTuneAttachmentTypeUsingFilename(LIFEAttachmentType * __nonnull attachmentType, NSString * __nonnull filename);
