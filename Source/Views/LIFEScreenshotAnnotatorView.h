//
//  LIFEScreenshotAnnotatorView.h
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

#import <UIKit/UIKit.h>
#import "LIFEAnnotation.h"

@class LIFEAnnotatedImage;
@class LIFEAnnotationView;
@class LIFEAnnotatedImageView;

@interface LIFEScreenshotAnnotatorView : UIView

@property (nonatomic, readonly) LIFEAnnotationType selectedAnnotationType;
@property (nonatomic, readonly) NSArray<LIFEAnnotationView *> *annotationViews;
- (LIFEAnnotatedImageView *)annotatedImageView;
- (UIImageView *)sourceImageView;

- (instancetype)initWithAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage;

- (void)addAnnotationView:(LIFEAnnotationView *)annotationView;
- (void)animateAddedAnnotationView:(LIFEAnnotationView *)annotationView;
- (void)removeAnnotationView:(LIFEAnnotationView *)annotationView;

// You may want to call this when views underneath loupe annotations move/change
- (void)updateLoupeAnnotationViewsWithSourceImage:(UIImage *)sourceImage;

- (LIFEAnnotationView *)annotationViewAtLocation:(CGPoint)location;

#pragma mark - Toolbars

@property (nonatomic, readonly) BOOL toolbarsHidden;
- (void)setToolbarsHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(void))completion;

+ (NSTimeInterval)toolbarTransitionDuration;

@end
