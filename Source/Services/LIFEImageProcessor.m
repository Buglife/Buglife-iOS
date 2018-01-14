//
//  LIFEImageProcessor.m
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

#import "LIFEImageProcessor.h"
#import "LIFEAnnotatedImage.h"
#import "LIFEGeometry.h"
#import "LIFEBlurAnnotationView.h"
#import "LIFELoupeAnnotationView.h"
#import "LIFEArrowAnnotationView.h"
#import "UIImage+LIFEAdditions.h"

@interface LIFEImageProcessor ()

@property (nonatomic, nonnull) NSCache<LIFEImageCacheKey *, UIImage *> *imageCache;
@property (nonatomic, nonnull) NSOperationQueue *operationQueue;

// We use a seperate queue for source images for loupes, since
// the user might be moving a blur annotation around underneath a loupe,
// and we don't want to constantly re-render for every frame since this is slow.
// Having a separate queue lets us cancel "old" renderings
@property (nonatomic, nonnull) NSOperationQueue *loupeQueue;

// This queue is used for operations that flatten *all* annotations
@property (nonatomic, nonnull) NSOperationQueue *flattenQueue;

@end

@implementation LIFEImageProcessor

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageCache = [[NSCache alloc] init];
        
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        
        _loupeQueue = [[NSOperationQueue alloc] init];
        _loupeQueue.maxConcurrentOperationCount = 1;
        
        _flattenQueue = [[NSOperationQueue alloc] init];
        _flattenQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - Public

- (void)getScaledImageForImageIdentifier:(LIFEImageIdentifier *)imageIdentifier sourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize toQueue:(dispatch_queue_t)completionQueue completion:(LIFEImageProcessorResultBlock)completion
{
    targetSize = LIFECGSizeIntegral(targetSize);
    __weak typeof(self) weakSelf = self;

    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        __strong LIFEImageProcessor *strongSelf = weakSelf;
        if (strongSelf) {
            UIImage *result = [self _scaledImageForImageIdentifier:imageIdentifier sourceImage:sourceImage targetSize:targetSize];
            
            dispatch_async(completionQueue, ^{
                completion(imageIdentifier, result);
            });
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

- (void)getBlurredScaledImageForImageIdentifier:(LIFEImageIdentifier *)imageIdentifier sourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize toQueue:(dispatch_queue_t)completionQueue completion:(LIFEImageProcessorResultBlock)completion
{
    targetSize = LIFECGSizeIntegral(targetSize);
    __weak typeof(self) weakSelf = self;
    
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        __strong LIFEImageProcessor *strongSelf = weakSelf;
        if (strongSelf) {
            UIImage *result = [strongSelf _blurredScaledImageForImageIdentifier:imageIdentifier sourceImage:sourceImage targetSize:targetSize];
            
            dispatch_async(completionQueue, ^{
                completion(imageIdentifier, result);
            });
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

- (void)getLoupeSourceScaledImageForAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize toQueue:(dispatch_queue_t)completionQueue completion:(LIFEImageProcessorResultBlock)completion
{
    // Annotated images can be mutable!
    annotatedImage = annotatedImage.copy;
    targetSize = LIFECGSizeIntegral(targetSize);
    __weak typeof(self) weakSelf = self;
    
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        __strong LIFEImageProcessor *strongSelf = weakSelf;
        if (strongSelf) {
            LIFEImageIdentifier *imageIdentifier = annotatedImage.identifier;
            UIImage *result = [strongSelf _loupeSourceScaledImageForAnnotatedImage:annotatedImage targetSize:targetSize];
            
            dispatch_async(completionQueue, ^{
                completion(imageIdentifier, result);
            });
        }
    }];
    
    [self.loupeQueue cancelAllOperations];
    [self.loupeQueue addOperation:operation];
}

- (void)clearImageCache
{
    [self.imageCache removeAllObjects];
}

- (void)getFlattenedScaledImageForAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize toQueue:(dispatch_queue_t)completionQueue completion:(LIFEImageProcessorResultBlock)completion
{
    // Annotated images can be mutable!
    annotatedImage = annotatedImage.copy;
    targetSize = LIFECGSizeIntegral(targetSize);
    __weak typeof(self) weakSelf = self;
    
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        __strong LIFEImageProcessor *strongSelf = weakSelf;
        if (strongSelf) {
            LIFEImageIdentifier *imageIdentifier = annotatedImage.identifier;
            UIImage *result = [strongSelf _flattenedScaledImageForAnnotatedImage:annotatedImage targetSize:targetSize];

            dispatch_async(completionQueue, ^{
                completion(imageIdentifier, result);
            });
        }
    }];
    
    [self.flattenQueue addOperation:operation];
}

- (nonnull UIImage *)syncGetFlattenedScaledImageForAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize
{
    return [self _flattenedScaledImageForAnnotatedImage:annotatedImage targetSize:targetSize];
}

#pragma mark - Cache clearing

- (void)clearCachedLoupeSourceScaledImagesForAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize
{
    // Annotated images can be mutable!
    annotatedImage = annotatedImage.copy;
    LIFEImageIdentifier *imageIdentifier = annotatedImage.identifier;
    LIFEImageCacheKey *cacheKey = [LIFEImageProcessor _blurredImageCacheKeyForImageIdentifier:imageIdentifier targetSize:targetSize];
    [self.imageCache removeObjectForKey:cacheKey];
    
    cacheKey = [LIFEImageProcessor _loupeSourceImageCacheKeyForImageIdentifier:imageIdentifier targetSize:targetSize];
    [self.imageCache removeObjectForKey:cacheKey];
}

#pragma mark - Private

- (nonnull UIImage *)_scaledImageForImageIdentifier:(LIFEImageIdentifier *)imageIdentifier sourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    targetSize = LIFECGSizeIntegral(targetSize);
    NSCache *imageCache = self.imageCache;
    LIFEImageCacheKey *cacheKey = [LIFEImageProcessor _imageCacheKeyForImageIdentifier:imageIdentifier targetSize:targetSize];
    UIImage *result = [imageCache objectForKey:cacheKey];
    
    if (result == nil) {
        result = [LIFEUIImage image:sourceImage scaledToSize:targetSize];
        [imageCache setObject:result forKey:cacheKey];
    }
    
    return result;
}

- (nonnull UIImage *)_blurredScaledImageForImageIdentifier:(LIFEImageIdentifier *)imageIdentifier sourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    targetSize = LIFECGSizeIntegral(targetSize);
    NSCache *imageCache = self.imageCache;
    LIFEImageCacheKey *cacheKey = [LIFEImageProcessor _blurredImageCacheKeyForImageIdentifier:imageIdentifier targetSize:targetSize];
    UIImage *result = [imageCache objectForKey:cacheKey];
    
    if (result == nil) {
        // Get a scaled version of the image
        result = [self _scaledImageForImageIdentifier:imageIdentifier sourceImage:sourceImage targetSize:targetSize];
        
        // Blur the image
        result = [LIFEUIImage image:result pixelatedImageWithAmount:LIFEDefaultBlurAmount];
        
        // Then cache it
        [imageCache setObject:result forKey:cacheKey];
    }
    
    return result;
}

- (nonnull UIImage *)_loupeSourceScaledImageForAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize
{
    targetSize = LIFECGSizeIntegral(targetSize);
    NSCache *imageCache = self.imageCache;
    LIFEImageIdentifier *imageIdentifier = annotatedImage.identifier;
    LIFEImageCacheKey *cacheKey = [LIFEImageProcessor _loupeSourceImageCacheKeyForImageIdentifier:imageIdentifier targetSize:targetSize];
    UIImage *result = [imageCache objectForKey:cacheKey];
    
    if (result == nil) {
        UIImage *sourceImage = annotatedImage.sourceImage;
        UIImage *scaledSourceImage = [self _scaledImageForImageIdentifier:imageIdentifier sourceImage:sourceImage targetSize:targetSize];
        UIImage *blurredScaledSourceImage = [self _blurredScaledImageForImageIdentifier:imageIdentifier sourceImage:sourceImage targetSize:targetSize];
        
        // Generate the image
        LIFEAnnotationArray *blurAnnotations = annotatedImage.blurAnnotations;
        result = [LIFEImageProcessor _flattenedImageWithSourceImage:scaledSourceImage blurredImage:blurredScaledSourceImage blurAnnotations:blurAnnotations];
        
        // Then cache it
        [imageCache setObject:result forKey:cacheKey];
    }
    
    return result;
}

- (nonnull UIImage *)_flattenedScaledImageForAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage targetSize:(CGSize)targetSize
{
    targetSize = LIFECGSizeIntegral(targetSize);
    NSCache *imageCache = self.imageCache;
    LIFEImageIdentifier *imageIdentifier = annotatedImage.identifier;
    LIFEImageCacheKey *cacheKey = [LIFEImageProcessor _flattenedImageCacheKeyForImageIdentifier:imageIdentifier targetSize:targetSize];
    UIImage *result = [imageCache objectForKey:cacheKey];
    
    if (result == nil) {
        // Get the blurred flattened image
        result = [self _loupeSourceScaledImageForAnnotatedImage:annotatedImage targetSize:targetSize];
        
        // Flatten using the other annotations
        NSArray *arrowAnnotations = annotatedImage.arrowAnnotations;
        NSArray *loupeAnnotations = annotatedImage.loupeAnnotations;
        
        result = [LIFEImageProcessor _flattenedImageWithLoupeSourceImage:result loupeAnnotations:loupeAnnotations arrowAnnotations:arrowAnnotations];
        
        [imageCache setObject:result forKey:cacheKey];
    }
    
    return result;
}

#pragma mark - Image cache keys

+ (LIFEImageCacheKey *)_imageCacheKeyForImageIdentifier:(LIFEImageIdentifier *)imageIdentifier targetSize:(CGSize)targetSize
{
    return [NSString stringWithFormat:@"%@-%@", imageIdentifier, NSStringFromCGSize(targetSize)];
}

+ (LIFEImageCacheKey *)_blurredImageCacheKeyForImageIdentifier:(LIFEImageIdentifier *)imageIdentifier targetSize:(CGSize)targetSize
{
    return [NSString stringWithFormat:@"blurred-%@-%@", imageIdentifier, NSStringFromCGSize(targetSize)];
}

+ (LIFEImageCacheKey *)_loupeSourceImageCacheKeyForImageIdentifier:(LIFEImageIdentifier *)imageIdentifier targetSize:(CGSize)targetSize
{
    return [NSString stringWithFormat:@"loupe-source-%@-%@", imageIdentifier, NSStringFromCGSize(targetSize)];
}

+ (LIFEImageCacheKey *)_flattenedImageCacheKeyForImageIdentifier:(LIFEImageIdentifier *)imageIdentifier targetSize:(CGSize)targetSize
{
    return [NSString stringWithFormat:@"flattened-%@-%@", imageIdentifier, NSStringFromCGSize(targetSize)];
}

+ (UIImage *)_flattenedImageWithSourceImage:(UIImage *)sourceImage blurredImage:(UIImage *)blurredImage blurAnnotations:(LIFEAnnotationArray *)blurAnnotations
{
    CGSize size = sourceImage.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    [sourceImage drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (LIFEAnnotation *blurAnnotation in blurAnnotations) {
        LIFEAnnotationLayer *annotationLayer = [LIFEBlurAnnotationLayer layer];
        annotationLayer.frame = rect;
        annotationLayer.annotation = blurAnnotation;
        annotationLayer.scaledSourceImage = blurredImage;
        
        CGContextSaveGState(context);
        [annotationLayer drawForFlattenedImageInContext:context];
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)_flattenedImageWithLoupeSourceImage:(UIImage *)sourceImage loupeAnnotations:(LIFEAnnotationArray *)loupeAnnotations arrowAnnotations:(LIFEAnnotationArray *)arrowAnnotations
{
    CGSize size = sourceImage.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    [sourceImage drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (LIFEAnnotation *loupeAnnotation in loupeAnnotations) {
        LIFEAnnotationLayer *annotationLayer = [LIFELoupeAnnotationLayer layer];
        annotationLayer.frame = rect;
        annotationLayer.annotation = loupeAnnotation;
        annotationLayer.scaledSourceImage = sourceImage;
        
        CGContextSaveGState(context);
        [annotationLayer drawForFlattenedImageInContext:context];
        CGContextRestoreGState(context);
    }
    
    for (LIFEAnnotation *arrowAnnotation in arrowAnnotations) {
        LIFEAnnotationLayer *annotationLayer = [LIFEArrowAnnotationLayer layer];
        annotationLayer.frame = rect;
        annotationLayer.annotation = arrowAnnotation;
        annotationLayer.scaledSourceImage = sourceImage;
        
        CGContextSaveGState(context);
        [annotationLayer drawForFlattenedImageInContext:context];
        CGContextRestoreGState(context);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
