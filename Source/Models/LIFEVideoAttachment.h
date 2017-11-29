//
//  LIFEScreenRecording.h
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
#import "LIFEUserFacingAttachment.h"

@class UIImage;

@interface LIFEVideoAttachment : NSObject <LIFEUserFacingAttachment>

@property (nonnull, readonly) NSURL *url;
@property (nonnull, readonly) NSString *uniformTypeIdentifier;
@property (nonnull, readonly) NSString *filename;
@property (nonnull, readonly) NSDate *creationDate;
@property (nonatomic, getter=isProcessing) BOOL processing;

- (nonnull instancetype)initWithFileURL:(nonnull NSURL *)url uniformTypeIdentifier:(nonnull NSString *)uniformTypeIdentifier filename:(nonnull NSString *)filename isProcessing:(BOOL)processing;
- (nullable UIImage *)getThumbnail;

@end
