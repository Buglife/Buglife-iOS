//
//  LIFEAnnotatedImage.h
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
#import "LIFEImageFormat.h"
#import "Buglife+Protected.h"
#import "LIFEAnnotationView.h"
#import "LIFEUserFacingAttachment.h"

@class LIFEAnnotation;

typedef NSArray<LIFEAnnotation *> LIFEAnnotationArray;
typedef NSString LIFEAnnotatedImageID;

@interface LIFEAnnotatedImage : NSObject <NSCopying, NSMutableCopying, LIFEUserFacingAttachment>

@property (nonnull, nonatomic, readonly) UIImage *sourceImage;
@property (nonnull, nonatomic, readonly) LIFEAnnotationArray *annotations;
@property (nonnull, nonatomic, readonly) NSString *filename;
@property (nonatomic, readonly) LIFEImageFormat imageFormat;

// This is a unique identifier for the annotated image,
// which can be used for cache keys, etc.
@property (nonnull, nonatomic, readonly) LIFEAnnotatedImageID *identifier;

- (null_unspecified instancetype)init NS_UNAVAILABLE;

// Automatically names the screenshot
- (nonnull instancetype)initWithScreenshot:(nonnull UIImage *)screenshot;

- (nonnull instancetype)initWithSourceImage:(nonnull UIImage *)sourceImage filename:(nonnull NSString *)filename format:(LIFEImageFormat)format;

- (nonnull instancetype)initWithSourceImage:(nonnull UIImage *)sourceImage filename:(nonnull NSString *)filename annotations:(nonnull LIFEAnnotationArray *)annotations format:(LIFEImageFormat)format;

- (nonnull LIFEAnnotationArray *)freeformAnnotations;
- (nonnull LIFEAnnotationArray *)arrowAnnotations;
- (nonnull LIFEAnnotationArray *)loupeAnnotations;
- (nonnull LIFEAnnotationArray *)blurAnnotations;

@end

@interface LIFEMutableAnnotatedImage : LIFEAnnotatedImage

- (void)addAnnotation:(nonnull LIFEAnnotation *)annotation;
- (void)removeAnnotation:(nonnull LIFEAnnotation *)annotation;
- (void)replaceAnnotation:(nonnull LIFEAnnotation *)oldAnnotation withAnnotation:(nonnull LIFEAnnotation *)newAnnotation;

@end
