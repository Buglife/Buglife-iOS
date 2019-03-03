//
//  LIFEAnnotatedImageView.h
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

@class LIFEAnnotationView;
@class LIFEAnnotatedImage;

@interface LIFEAnnotatedImageView : UIView

@property (nonatomic, readonly, nonnull) NSArray<LIFEAnnotationView *> *annotationViews;
@property (nonatomic, readonly, nonnull) UIImageView *sourceImageView;

- (nonnull instancetype)initWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage;

- (void)addAnnotationView:(nonnull LIFEAnnotationView *)annotationView;
- (void)animateAddedAnnotationView:(nonnull LIFEAnnotationView *)annotationView;
- (void)removeAnnotationView:(nonnull LIFEAnnotationView *)annotationView;
- (void)updateLoupeAnnotationViewsWithSourceImage:(nonnull UIImage *)sourceImage;
- (CGFloat)aspectRatio;
- (nullable LIFEAnnotationView *)annotationViewAtLocation:(CGPoint)location;

@end
