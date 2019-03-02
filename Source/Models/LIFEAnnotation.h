//
//  LIFEAnnotation.h
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

typedef NS_ENUM(NSInteger, LIFEAnnotationType)
{
    LIFEAnnotationTypeArrow,
    LIFEAnnotationTypeLoupe,
    LIFEAnnotationTypeBlur,
    LIFEAnnotationTypeFreeform
};

@interface LIFEAnnotation : NSObject <NSCopying>

@property (nonatomic, readonly) LIFEAnnotationType annotationType;
@property (nonatomic, readonly) CGVector startVector;
@property (nonatomic, readonly) CGVector endVector;
@property (nonatomic, readonly, nullable) UIBezierPath *bezierPath;

- (null_unspecified instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithAnnotationType:(LIFEAnnotationType)annotationType startVector:(CGVector)startVector endVector:(CGVector)endVector NS_DESIGNATED_INITIALIZER;
+ (nonnull instancetype)freeformAnnotationWithBezierPath:(nonnull UIBezierPath *)bezierPath;
@end
