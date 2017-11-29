//
//  LIFEAnnotatedImage.m
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

#import "LIFEAnnotatedImage.h"
#import "LIFEAnnotation.h"
#import "NSArray+LIFEAdditions.h"

static NSUInteger sAnnotatedImageCount = 0;
static NSString * const LIFEScreenshotDefaultFilename = @"Screenshot.png";

@interface LIFEAnnotatedImage ()

@property (nonatomic) UIImage *sourceImage;
@property (nonatomic, copy) LIFEAnnotationArray *annotations;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) LIFEAnnotatedImageID *identifier;
@property (nonatomic) LIFEImageFormat imageFormat;

@end

@implementation LIFEAnnotatedImage

- (instancetype)init
{
    NSAssert(NO, @"Please use -initPrivate");
    return nil;
}

- (nonnull instancetype)initPrivate
{
    self = [super init];
    if (self) {
        sAnnotatedImageCount += 1;
        _identifier = [NSString stringWithFormat:@"%@", @(sAnnotatedImageCount)];
    }
    return self;
}

- (nonnull instancetype)initWithScreenshot:(nonnull UIImage *)screenshot
{
    return [self initWithSourceImage:screenshot filename:LIFEScreenshotDefaultFilename annotations:@[] format:LIFEImageFormatPNG];
}

- (nonnull instancetype)initWithSourceImage:(nonnull UIImage *)sourceImage filename:(nonnull NSString *)filename format:(LIFEImageFormat)format
{
    return [self initWithSourceImage:sourceImage filename:filename annotations:@[] format:format];
}

- (nonnull instancetype)initWithSourceImage:(nonnull UIImage *)sourceImage filename:(nonnull NSString *)filename annotations:(nonnull LIFEAnnotationArray *)annotations format:(LIFEImageFormat)format
{
    self = [self initPrivate];
    if (self) {
        _sourceImage = sourceImage;
        _filename = filename;
        _annotations = [annotations copy];
        _imageFormat = format;
    }
    return self;
}

- (LIFEAnnotationArray *)arrowAnnotations
{
    return [self.annotations life_filteredArrayUsingBlock:^BOOL(LIFEAnnotation *obj) {
        return obj.annotationType == LIFEAnnotationTypeArrow;
    }];
}

- (LIFEAnnotationArray *)loupeAnnotations
{
    return [self.annotations life_filteredArrayUsingBlock:^BOOL(LIFEAnnotation *obj) {
        return obj.annotationType == LIFEAnnotationTypeLoupe;
    }];
}

- (LIFEAnnotationArray *)blurAnnotations
{
    return [self.annotations life_filteredArrayUsingBlock:^BOOL(LIFEAnnotation *obj) {
        return obj.annotationType == LIFEAnnotationTypeBlur;
    }];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    LIFEAnnotatedImage *annotatedImage = [[[self class] allocWithZone:zone] initPrivate];
    annotatedImage.sourceImage = _sourceImage;
    annotatedImage.annotations = _annotations;
    annotatedImage.filename = _filename;
    annotatedImage.identifier = _identifier;
    annotatedImage.imageFormat = _imageFormat;
    return annotatedImage;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    LIFEMutableAnnotatedImage *annotatedImage = [[LIFEMutableAnnotatedImage allocWithZone:zone] initPrivate];
    annotatedImage.sourceImage = _sourceImage;
    annotatedImage.annotations = _annotations;
    annotatedImage.filename = _filename;
    annotatedImage.identifier = _identifier;
    annotatedImage.imageFormat = _imageFormat;
    return annotatedImage;
}

@end

@implementation LIFEMutableAnnotatedImage

- (void)addAnnotation:(LIFEAnnotation *)annotation
{
    self.annotations = [self.annotations arrayByAddingObject:annotation];
}

- (void)removeAnnotation:(LIFEAnnotation *)annotation
{
    NSMutableArray *annotations = [self.annotations mutableCopy];
    [annotations removeObject:annotation];
    self.annotations = [NSArray arrayWithArray:annotations];
}

- (void)replaceAnnotation:(LIFEAnnotation *)oldAnnotation withAnnotation:(LIFEAnnotation *)newAnnotation
{
    NSMutableArray *annotations = [self.annotations mutableCopy];
    NSUInteger oldIndex = [annotations indexOfObject:oldAnnotation];
    
    if (oldIndex == NSNotFound) {
        // Fix for crash reported in https://github.com/Buglife/Buglife-iOS/issues/21
        return;
    }
    
    [annotations replaceObjectAtIndex:oldIndex withObject:newAnnotation];
    self.annotations = [NSArray arrayWithArray:annotations];
}

@end
