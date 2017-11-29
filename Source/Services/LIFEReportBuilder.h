//
//  LIFEReportBuilder.h
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

extern NSString * __nonnull const LIFEReportBuilderAnnotatedImagesDidChangeNotification;

@class LIFEReproStep;
@class LIFEReport;
@class UIImage;
@class LIFEAnnotatedImage;
@class LIFEReportAttachmentImpl;
@class LIFEAttribute;
@class LIFEVideoAttachment;
@protocol LIFEUserFacingAttachment;

@interface LIFEReportBuilder : NSObject

@property (nonatomic, copy, nullable) NSString *whatHappened;
@property (nonatomic, copy, nullable) NSString *component;
@property (nonatomic, copy, nullable) NSArray<LIFEReproStep *> *reproSteps;
@property (nonatomic, copy, nullable) NSString *expectedResults;
@property (nonatomic, copy, nullable) NSString *actualResults;
@property (nonatomic, nullable) UIImage *screenshot;
@property (nonatomic, nullable) NSDate *creationDate;
@property (nonatomic, copy, nullable) NSString *userIdentifier;
@property (nonatomic, copy, nullable) NSString *userEmail;
@property (nonatomic) LIFEInvocationOptions invocationMethod;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, LIFEAttribute *> *attributes;
@property (nonnull, nonatomic, copy, readonly) NSArray<LIFEReportAttachmentImpl *> *nonImageAttachments;
// This should only be accessed on the main thread!
@property (nonnull, nonatomic, copy, readonly) NSArray<LIFEUserFacingAttachment> *userFacingAttachments;

- (void)addAttachment:(nonnull LIFEReportAttachmentImpl *)attachment;
- (void)addAttachments:(nonnull NSArray<LIFEReportAttachmentImpl *> *)attachments;

- (void)addAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage;
- (void)replaceAnnotatedImageAtIndex:(NSUInteger)index withAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage;
- (void)deleteAnnotatedImageAtIndex:(NSUInteger)index;

- (void)addVideoAttachment:(nonnull LIFEVideoAttachment *)videoAttachment;

- (void)buildReportToQueue:(nonnull dispatch_queue_t)completionQueue completion:(nonnull void (^)(LIFEReport * __nonnull report))completionHandler;

@end
