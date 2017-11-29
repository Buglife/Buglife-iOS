//
//  LIFEAnnotation.m
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

#import "LIFEAnnotation.h"

@implementation LIFEAnnotation

#pragma mark - Lifecycle

- (nonnull instancetype)initWithAnnotationType:(LIFEAnnotationType)annotationType startVector:(CGVector)startVector endVector:(CGVector)endVector
{
    self = [super init];
    if (self) {
        _annotationType = annotationType;
        _startVector = startVector;
        _endVector = endVector;
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    LIFEAnnotation *annotation = [[[self class] allocWithZone:zone] initWithAnnotationType:_annotationType startVector:_startVector endVector:_endVector];
    return annotation;
}

#pragma mark - Debugging

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@ (%@): %p>", NSStringFromClass([self class]), [self _annotationTypeString], self];
}

#pragma mark - Private methods

- (NSString *)_annotationTypeString
{
    switch (self.annotationType) {
        case LIFEAnnotationTypeArrow:
            return @"Arrow";
        case LIFEAnnotationTypeLoupe:
            return @"Loupe";
        case LIFEAnnotationTypeBlur:
            return @"Blur";
    }
}

@end
