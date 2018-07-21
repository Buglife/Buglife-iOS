//
//  LIFEImageFormat.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LIFEImageFormat) {
    LIFEImageFormatUnknown = 0,
    LIFEImageFormatPNG,
    LIFEImageFormatJPEG,
    LIFEImageFormatHEIC
};

#pragma mark - LIFEImageFormat / UTI conversions

LIFEImageFormat LIFEImageFormatFromUniformTypeIdentifierAndFilename(NSString * __nonnull uniformTypeIdentifier, NSString * __nullable filename);
NSString * __nonnull LIFEImageFormatToImageUniformTypeIdentifier(LIFEImageFormat imageFormat);
LIFEImageFormat LIFEImageFormatInferredFromFilename(NSString * __nullable filename);

#pragma mark - Core graphics wrappers

NSData * __nonnull LIFEImageRepresentationWithImageFormat(LIFEImageFormat imageFormat, UIImage * __nonnull image, CGFloat compressionQuality);

// Returns an image resized for the given maximum filesize
NSData * __nonnull LIFEImageRepresentationWithImageFormatAndMaximumSize(LIFEImageFormat imageFormat, UIImage * __nonnull image, CGFloat compressionQuality, NSUInteger maximumFilesize);
