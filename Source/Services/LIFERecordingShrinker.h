//
//  LIFERecordingShrinker.h
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

@class LIFEVideoAttachment;

NS_ASSUME_NONNULL_BEGIN
typedef void (^LIFERecordingShrinkerCompletion)(NSURL *outputURL);
@interface LIFERecordingShrinker : NSObject
- (instancetype)initWithRecording:(LIFEVideoAttachment *)recording;
- (instancetype)init NS_UNAVAILABLE;
- (void)startShrinkOnQueue:(dispatch_queue_t)queue completionHandler:(LIFERecordingShrinkerCompletion)completionHandler;
- (void)startShrinkOnOperationQueue:(NSOperationQueue *)opq completionHandler:(LIFERecordingShrinkerCompletion)completionHandler;
@property (nonatomic, readonly, assign) float progress; // 0.0f-1.0f
@property (nonatomic, readonly) LIFEVideoAttachment *recording;
@property (nonatomic, readonly) NSURL *outputURL;
@end
NS_ASSUME_NONNULL_END
