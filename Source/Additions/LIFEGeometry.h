//
//  LIFEGeometry.h
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

CGPoint LIFECGPointAdd(CGPoint p1, CGPoint p2);
CGSize LIFECGSizeIntegral(CGSize size);
CGSize LIFECGSizeAspectFill(CGSize aspectRatio, CGSize minimumSize);
BOOL LIFECGSizeEqualToSizeWithPrecision(CGSize size1, CGSize size2, CGFloat precision);
CGFloat LIFECGPointDistance(CGPoint point1, CGPoint point2);

// Given two CGPoints, "extends" the endPoint such that the distance between
// the given startPoint and the returned endPoint is equal to the given distance
CGPoint LIFEEndpointAdjustedForDistance(CGPoint startPoint, CGPoint endPoint, CGFloat distance);
CGPoint LIFEEndpointAdjustedForMinimumDistance(CGPoint startPoint, CGPoint endPoint, CGFloat minimumDistance);
CGVector LIFEEndVectorAdjustedForMinimumDistance(CGVector startVector, CGVector endVector, CGSize boundsSize, CGFloat minimumDistance);

#pragma mark - CGPoint <-> CGVector conversions

CGPoint LIFEPointFromVectorAndSize(CGVector vector, CGSize size);
CGVector LIFEVectorFromPointAndSize(CGPoint point, CGSize size);

CGPoint LIFECGPointApplyRotation(CGPoint pointToRotate, CGPoint anchor, CGFloat angleInRadians);
CGPoint LIFECGPointApplyScale(CGPoint pointToScale, CGPoint anchor, CGFloat scaleAmount);
