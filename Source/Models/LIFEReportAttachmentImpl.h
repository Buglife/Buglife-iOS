//
//  LIFEAttachment.h
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

extern NSString * __nonnull const LIFEScreenshotDefaultFilename;

@class UIImage;
@class LIFEAttachment;
@class LIFEVideoAttachment;

@interface LIFEReportAttachmentImpl : NSObject <NSCoding>

@property (nonatomic, nonnull, readonly) NSData *attachmentData;
// This is a UTI (Uniform Type Identifier).
// See https://developer.apple.com/library/ios/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
@property (nonatomic, nonnull, readonly) NSString *uniformTypeIdentifier;
@property (nonatomic, nullable, readonly) NSString *filename;

// Returns the AwesomeLog version, if this is a log attachment >= 2.0.
// For previous versions (ASL logs), we did not include a logVersion.
@property (nonatomic, nullable, readonly) NSString *logVersion;

- (nonnull instancetype)initWithData:(nonnull NSData *)data uniformTypeIdentifier:(nonnull NSString *)uti filename:(nonnull NSString *)filename;
- (nonnull instancetype)initWithImage:(nonnull UIImage *)image filename:(nonnull NSString *)filename;
- (nonnull instancetype)initWithLogData:(nonnull NSData *)logData;
- (_Null_unspecified instancetype)init NS_UNAVAILABLE;

- (nonnull NSDictionary *)JSONDictionary;
- (NSUInteger)size;
- (BOOL)isImageAttachment;

@end
