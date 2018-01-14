//
//  LIFEImageProcessor.h
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
#import "LIFEAnnotatedImage.h"

typedef NSString LIFEImageCacheKey;
typedef LIFEAnnotatedImageID LIFEImageIdentifier;
typedef void (^LIFEImageProcessorResultBlock)(LIFEImageIdentifier * _Null_unspecified identifier, UIImage * __nonnull result);

@interface LIFEImageProcessor : NSObject

- (void)getBlurredScaledImageForImageIdentifier:(nonnull LIFEImageIdentifier *)imageIdentifier sourceImage:(nonnull UIImage *)sourceImage targetSize:(CGSize)targetSize toQueue:(nonnull dispatch_queue_t)completionQueue completion:(nonnull LIFEImageProcessorResultBlock)completion;

// Gets a flattened scaled image, with blur annotations on it. This can be used
// to get a source image for loupe annotations
- (void)getLoupeSourceScaledImageForAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize toQueue:(nonnull dispatch_queue_t)completionQueue completion:(nonnull LIFEImageProcessorResultBlock)completion;

// Gets a flattened scaled image, with all annotations on it.
- (void)getFlattenedScaledImageForAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize toQueue:(nonnull dispatch_queue_t)completionQueue completion:(nonnull LIFEImageProcessorResultBlock)completion;

- (nonnull UIImage *)syncGetFlattenedScaledImageForAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize;

#pragma mark - Cache clearing

- (void)clearImageCache;
- (void)clearCachedLoupeSourceScaledImagesForAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize;

@end
