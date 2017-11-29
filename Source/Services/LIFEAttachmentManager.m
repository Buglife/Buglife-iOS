//
//  LIFEAttachmentManager.m
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

#import "LIFEAttachmentManager.h"
#import "LIFEReportAttachmentImpl.h"
#import "LIFEMacros.h"

#import "LIFEImageFormat.h"
#import "UIImage+LIFEAdditions.h"

static NSString * const LIFEErrorDomain = @"com.buglife.buglife";
static const NSInteger kErrorCodeInvalidAttachmentType = 80;
static const NSInteger kErrorCodeInvalidAttachmentData = 81;
static const NSInteger kErrorCodeTotalFilesizeExceeded = 82;
static const NSInteger kErrorCodeMaxAttachmentCountExceeded = 83;

// Please don't *actually* try to upload 50 MB... this is strictly enforced
// here to catch programmer error :)
static const NSUInteger kMaxTotalAttachmentSize = 50 * 1000 * 1000; // 50 MB
static const NSUInteger kMaxAttachmentCount = 100;
static const NSUInteger kMaxImageAttachmentSizeWhenTotalAttachmentSizeExceeded = 250 * 1000; // 250 KB

@interface LIFEAttachmentManager ()

@property (nonatomic) BOOL requestsOpen;
@property (nonatomic) NSArray<LIFEReportAttachmentImpl *> *candidateAttachments; // Attachments that the user added via the public interface
@property (nonatomic) NSArray<LIFEReportAttachmentImpl *> *settledAttachments;  // Attachments for the outgoing report
@property (nonatomic) dispatch_queue_t attachmentQueue; // Queue for accessing the above attachment properties

@end

@implementation LIFEAttachmentManager

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        _requestsOpen = NO;
        _attachmentQueue = dispatch_queue_create("com.buglife.attachmentQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Opening / closing requests

- (void)asyncOpenRequestsForDuration:(NSTimeInterval)duration expirationHandler:(void (^)(void))expirationHandler
{
    NSParameterAssert([NSThread isMainThread]);

    __weak typeof(self) weakSelf = self;
    dispatch_async(_attachmentQueue, ^{
        __strong LIFEAttachmentManager *strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.requestsOpen = YES;
            
            // After opening the requests, wait some amount of time before expiring
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), strongSelf.attachmentQueue, ^{
                __strong LIFEAttachmentManager *strongSelf2 = weakSelf;
                if (strongSelf2) {
                    // If requests haven't been manually closed already...
                    if (strongSelf2.requestsOpen) {
                        if (expirationHandler) {
                            expirationHandler();
                        }
                        
                        [strongSelf2 _syncCloseRequestsAndSettleAttachments];
                    }
                }
            });
        }
    });
}

- (void)asyncCloseRequestsAndSettleAttachments
{
    NSParameterAssert([NSThread isMainThread]);

    __weak typeof(self) weakSelf = self;
    dispatch_async(_attachmentQueue, ^{
        __strong LIFEAttachmentManager *strongSelf = weakSelf;
        if (strongSelf) {
            [self _syncCloseRequestsAndSettleAttachments];
        }
    });
}

- (void)_syncCloseRequestsAndSettleAttachments
{
    self.requestsOpen = NO;
    self.settledAttachments = self.candidateAttachments;
    self.candidateAttachments = nil;
}

#pragma mark - Public methods

- (void)asyncFlushSettledAttachmentsToQueue:(dispatch_queue_t)queue completion:(void (^)(NSArray<LIFEReportAttachmentImpl *> *settledAttachments))completion
{
    NSParameterAssert([NSThread isMainThread]);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_attachmentQueue, ^{
        __strong LIFEAttachmentManager *strongSelf = weakSelf;
        if (strongSelf) {
            NSArray *settledAttachments = strongSelf.settledAttachments;
            
            // clear out settled attachments
            strongSelf.settledAttachments = nil;
            
            dispatch_async(queue, ^{
                completion(settledAttachments);
            });
        }
    });
}

- (BOOL)syncAddAttachmentWithData:(NSData *)attachmentData type:(NSString *)attachmentType filename:(NSString *)filename error:(NSError * __autoreleasing *)error requestsClosedHandler:(void (^)(void))requestsClosedHandler
{
    __block BOOL result = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_sync(_attachmentQueue, ^{
        __strong LIFEAttachmentManager *strongSelf = weakSelf;
        if (strongSelf) {
            result = [strongSelf _addAttachmentWithData:attachmentData type:attachmentType filename:filename error:error requestsClosedHandler:requestsClosedHandler];
        }
    });
    return result;
}

- (void)asyncAddAttachmentWithImage:(UIImage *)image filename:(NSString *)filename requestsClosedHandler:(void (^)(void))requestsClosedHandler
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_attachmentQueue, ^{
        __strong LIFEAttachmentManager *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf _addAttachmentWithImage:image filename:filename requestsClosedHandler:requestsClosedHandler];
        }
    });
}

- (BOOL)_addAttachmentWithData:(NSData *)attachmentData type:(NSString *)attachmentType filename:(NSString *)filename error:(NSError * _Nullable * _Nullable)error requestsClosedHandler:(void (^)(void))requestsClosedHandler
{
    if (self.requestsOpen == NO) {
        requestsClosedHandler();
    }

    //////////////////////////////////////////////////////////////
    // Make sure attachment data is not nil                     //
    //////////////////////////////////////////////////////////////
    
    if (attachmentData == nil) {
        if (error) {
            *error = [[self class] _errorWithCode:kErrorCodeInvalidAttachmentData filename:filename failureReason:@"Invalid attachmentData"];
        } else {
            LIFELogExtWarn(@"Buglife warning: attachmentData is nil");
        }
        
        return NO;
    }
    
    //////////////////////////////
    // Convert UTI if necessary //
    //////////////////////////////
    
    attachmentType = LIFEFineTuneAttachmentTypeUsingFilename(attachmentType, filename);
    
    //////////////////////////////
    // Make sure UTI is valid   //
    //////////////////////////////
    
    NSArray *validUTIs = @[LIFEAttachmentTypeIdentifierText, LIFEAttachmentTypeIdentifierJSON, LIFEAttachmentTypeIdentifierSqlite, LIFEAttachmentTypeIdentifierImage, LIFEAttachmentTypeIdentifierPNG, LIFEAttachmentTypeIdentifierJPEG];
    BOOL typeIsValid = [validUTIs containsObject:attachmentType];
    
    if (!typeIsValid) {
        if (error) {
            *error = [[self class] _errorWithCode:kErrorCodeInvalidAttachmentType filename:filename failureReason:[NSString stringWithFormat:@"Unexpected attachment type %@.", attachmentType]];
        } else {
            LIFELogExtWarn(@"Buglife warning: Invalid attachment type \"%@\"", attachmentType);
        }
        
        return NO;
    }
    
    //////////////////////////////////////////////////////////////
    // Check if attachment count was exceeded                   //
    //////////////////////////////////////////////////////////////

    if (self.candidateAttachments.count >= kMaxAttachmentCount) {
        if (error) {
            *error = [[self class] _errorWithCode:kErrorCodeMaxAttachmentCountExceeded filename:filename failureReason:@"Maximum attachment count exceeded."];
        }
        
        return  NO;
    }
    
    //////////////////////////////
    // Check total size         //
    //////////////////////////////

    NSUInteger expectedTotalSize = attachmentData.length + [self _totalSizeOfCandidateAttachments];
    
    if (expectedTotalSize > kMaxTotalAttachmentSize) {
        if (error) {
            NSString *failureReason = @"Attaching this file would exceed the total allowed attachment size.";
            *error = [[self class] _errorWithCode:kErrorCodeTotalFilesizeExceeded filename:filename failureReason:failureReason];
        }
        
        return NO;
    }
    
    //////////////////////////////
    // Success!                 //
    //////////////////////////////

    [self _addCandidateAttachmentWithData:attachmentData uniformTypeIdentifier:attachmentType filename:filename];
    
    return YES;
}

- (void)_addAttachmentWithImage:(UIImage *)image filename:(NSString *)filename requestsClosedHandler:(void (^)(void))requestsClosedHandler
{
    if (self.requestsOpen == NO) {
        requestsClosedHandler();
    }
    
    ////////////////////////////////////////////////////
    // Make sure image is not nil                     //
    ////////////////////////////////////////////////////
    
    if (image == nil) {
        LIFELogExtError(@"Buglife error: image is nil");
        return;
    }
    
    //////////////////////////////////////////////////////////////
    // Check if attachment count was exceeded                   //
    //////////////////////////////////////////////////////////////
    
    if (self.candidateAttachments.count >= kMaxAttachmentCount) {
        LIFELogExtError(@"Buglife error: Unable to attach image '%@': Maximum attachment count exceeded.", filename);
        return;
    }
    
    //////////////////////////////////
    // Determine image size         //
    //////////////////////////////////
    
    NSUInteger spaceRemaining = 0;
    NSUInteger totalSizeOfCandidateAttachments = [self _totalSizeOfCandidateAttachments];
    
    if (totalSizeOfCandidateAttachments < kMaxTotalAttachmentSize) {
        spaceRemaining = kMaxTotalAttachmentSize - totalSizeOfCandidateAttachments;
    } else {
        spaceRemaining = 0;
    }
    
    NSUInteger maxImageFilesize = MAX(spaceRemaining, kMaxImageAttachmentSizeWhenTotalAttachmentSizeExceeded);
    
    //////////////////////////////
    // Get image format         //
    //////////////////////////////
    
    LIFEImageFormat imageFormat = LIFEImageFormatInferredFromFilename(filename);
    
    if (imageFormat == LIFEImageFormatUnknown) {
        LIFELogIntInfo(@"Could not determine image format for image attachment '%@'; Will assume JPEG.", filename);
        imageFormat = LIFEImageFormatJPEG;
    }
    
    NSString *uniformTypeIdentifier = LIFEImageFormatToImageUniformTypeIdentifier(imageFormat);
    
    //////////////////
    // Resize image //
    //////////////////
    
    NSData *imageData = LIFEImageRepresentationWithImageFormatAndMaximumSize(imageFormat, image, 0.75, maxImageFilesize);
    
    //////////////////////////////
    // Success!                 //
    //////////////////////////////
    
    [self _addCandidateAttachmentWithData:imageData uniformTypeIdentifier:uniformTypeIdentifier filename:filename];
}

- (void)_addCandidateAttachmentWithData:(NSData *)attachmentData uniformTypeIdentifier:(NSString *)uniformTypeIdentifier filename:(NSString *)filename
{
    LIFEReportAttachmentImpl *attachment = [[LIFEReportAttachmentImpl alloc] initWithData:attachmentData uniformTypeIdentifier:uniformTypeIdentifier filename:filename];
    
    if (self.candidateAttachments == nil) {
        self.candidateAttachments = [[NSArray alloc] init];
    }
    
    self.candidateAttachments = [self.candidateAttachments arrayByAddingObject:attachment];
}

- (NSUInteger)_totalSizeOfCandidateAttachments
{
    NSUInteger result = 0;
    
    for (LIFEReportAttachmentImpl *attachment in self.candidateAttachments) {
        result += attachment.size;
    }
    
    return result;
}

+ (NSError *)_errorWithCode:(NSInteger)code filename:(NSString *)filename failureReason:(NSString *)failureReason
{
    NSString *description = [NSString stringWithFormat:@"Unable to attach file \"%@\".", filename];
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: description,
                               NSLocalizedFailureReasonErrorKey: failureReason
                               };
    return [NSError errorWithDomain:LIFEErrorDomain code:code userInfo:userInfo];
}

@end

LIFEAttachmentType *LIFEFineTuneAttachmentTypeUsingFilename(LIFEAttachmentType *attachmentType, NSString *filename)
{
    if ([attachmentType isEqualToString:LIFEAttachmentTypeIdentifierImage]) {
        NSString *lowercaseFilename = [filename lowercaseString];
        
        if ([lowercaseFilename hasSuffix:@"jpg"] || [lowercaseFilename hasSuffix:@"jpeg"]) {
            return LIFEAttachmentTypeIdentifierJPEG;
        } else if ([lowercaseFilename hasSuffix:@"png"]) {
            return LIFEAttachmentTypeIdentifierPNG;
        }
    }

    return attachmentType;
}
