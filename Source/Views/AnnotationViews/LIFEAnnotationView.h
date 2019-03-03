//
//  LIFEAnnotationView.h
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

typedef void (^LIFEAnnotationViewTrashCompletion)(void);

#pragma mark - Protocol

@class LIFEAnnotationView;

#pragma mark - View

@class LIFEAnnotation;
@class LIFEAnnotationLayer;

@interface LIFEAnnotationView : UIView

@property (nonnull, nonatomic) LIFEAnnotation *annotation;
@property (nonatomic, nullable) UIImage *scaledSourceImage;
@property (nonatomic, readonly) CGPoint startPoint;
@property (nonatomic, readonly) CGPoint endPoint;
@property (nonnull, nonatomic, readonly) UIColor *annotationFillColor;
@property (nonnull, nonatomic, readonly) UIColor *annotationStrokeColor;

- (null_unspecified instancetype)init NS_UNAVAILABLE;
- (null_unspecified instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (null_unspecified instancetype)initWithCoder:(null_unspecified NSCoder *)coder NS_UNAVAILABLE;
- (nonnull instancetype)initWithAnnotation:(nonnull LIFEAnnotation *)annotation NS_DESIGNATED_INITIALIZER;

- (CGRect)annotationRect;

// Popover menu uses the top-most control point returned
// by this method.
- (null_unspecified UIBezierPath *)pathForPopoverMenu;
- (void)animateToTrashCanRect:(CGRect)trashCanRect completion:(nonnull LIFEAnnotationViewTrashCompletion)completionHandler;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (nonnull LIFEAnnotationLayer *)annotationLayer;
// Generally used to determine whether a touch location intersects
// with an annotation. Note that an annotation view may be much larger
// than the annotation itself.
- (BOOL)containsLocation:(CGPoint)location;

@end

#pragma mark - Layer

@interface LIFEAnnotationLayer : CALayer

@property (nonatomic, nonnull) LIFEAnnotation *annotation;
@property (nonatomic, nullable) UIImage *scaledSourceImage;
@property (nonatomic, readonly) CGPoint startPoint;
@property (nonatomic, readonly) CGPoint endPoint;

- (CGRect)annotationRect;
- (void)drawForFlattenedImageInContext:(null_unspecified CGContextRef)context;

@end
