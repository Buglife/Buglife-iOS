//
//  LIFEImageFormat.m
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

#import "LIFEImageFormat.h"
#import "Buglife+Protected.h"
#import "UIImage+LIFEAdditions.h"

LIFEImageFormat LIFEImageFormatFromUniformTypeIdentifierAndFilename(NSString *uniformTypeIdentifier, NSString *filename)
{
    if ([uniformTypeIdentifier isEqualToString:LIFEAttachmentTypeIdentifierPNG]) {
        return LIFEImageFormatPNG;
    } else if ([uniformTypeIdentifier isEqualToString:LIFEAttachmentTypeIdentifierJPEG]) {
        return LIFEImageFormatJPEG;
    } else if ([uniformTypeIdentifier isEqualToString:LIFEAttachmentTypeIdentifierImage]) {
        return LIFEImageFormatInferredFromFilename(filename);
    } else {
        NSCAssert(NO, @"Unexpected uniform type identifier");
        return LIFEImageFormatInferredFromFilename(filename);
    }
}

LIFEImageFormat LIFEImageFormatInferredFromFilename(NSString *filename) {
    NSString *lowercasePathExtension = filename.pathExtension.lowercaseString;
    
    if ([lowercasePathExtension isEqualToString:@"jpg"] || [lowercasePathExtension isEqualToString:@"jpeg"]) {
        return LIFEImageFormatJPEG;
    } else if ([lowercasePathExtension isEqualToString:@"png"]) {
        return LIFEImageFormatPNG;
    } else {
        return LIFEImageFormatUnknown;
    }
}

NSString *LIFEImageFormatToImageUniformTypeIdentifier(LIFEImageFormat imageFormat)
{
    switch (imageFormat) {
        case LIFEImageFormatPNG:
            return LIFEAttachmentTypeIdentifierPNG;
        case LIFEImageFormatJPEG:
            return LIFEAttachmentTypeIdentifierJPEG;
        case LIFEImageFormatUnknown:
            return LIFEAttachmentTypeIdentifierImage;
    }
}

NSData *LIFEImageRepresentationWithImageFormat(LIFEImageFormat imageFormat, UIImage *image, CGFloat compressionQuality)
{
    switch (imageFormat) {
        case LIFEImageFormatPNG:
            return UIImagePNGRepresentation(image);
        case LIFEImageFormatJPEG:
            return UIImageJPEGRepresentation(image, compressionQuality);
        case LIFEImageFormatUnknown:
            // Assert in debug, and in production just return a JPEG
            NSCAssert(NO, @"Unexpected uniform type identifier");
            return UIImageJPEGRepresentation(image, compressionQuality);
    }
}

NSData *LIFEImageRepresentationWithImageFormatAndMaximumSize(LIFEImageFormat imageFormat, UIImage *image, CGFloat compressionQuality, NSUInteger maximumFilesize)
{
    switch (imageFormat) {
        case LIFEImageFormatPNG:
            return LIFEUIImagePNGRepresentationScaledForMaximumFilesize(image, maximumFilesize);
        case LIFEImageFormatJPEG:
            return LIFEUIImageJPEGRepresentationScaledForMaximumFilesize(image, maximumFilesize, compressionQuality);
        case LIFEImageFormatUnknown:
            // Assert in debug, and in production just return a JPEG
            NSCAssert(NO, @"Unexpected uniform type identifier");
            return LIFEUIImageJPEGRepresentationScaledForMaximumFilesize(image, maximumFilesize, compressionQuality);
    }
}
