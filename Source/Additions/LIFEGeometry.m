//
//  LIFEGeometry.m
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

#import "LIFEGeometry.h"

CGPoint LIFECGPointAdd(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGSize LIFECGSizeIntegral(CGSize size) {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    return CGRectIntegral(rect).size;
}

CGSize LIFECGSizeAspectFill(CGSize aspectRatio, CGSize minimumSize) {
    float mW = minimumSize.width / aspectRatio.width;
    float mH = minimumSize.height / aspectRatio.height;
    if( mH > mW )
        minimumSize.width = mH * aspectRatio.width;
    else if( mW > mH )
        minimumSize.height = mW * aspectRatio.height;
    return minimumSize;
}

BOOL LIFECGSizeEqualToSizeWithPrecision(CGSize size1, CGSize size2, CGFloat precision) {
    CGFloat widthDelta = fabs(size1.width - size2.width);
    CGFloat heightDelta = fabs(size1.height - size2.height);
    return ((widthDelta < precision) && (heightDelta < precision));
}

CGFloat LIFECGPointDistance(CGPoint point1, CGPoint point2) {
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    CGFloat radius = sqrt((xDist * xDist) + (yDist * yDist));
    return radius;
}

CGPoint LIFEEndpointAdjustedForDistance(CGPoint startPoint, CGPoint endPoint, CGFloat distance)
{
    CGFloat distanceSquared = powf(distance, 2.0);
    CGFloat width = endPoint.x - startPoint.x;
    CGFloat height = endPoint.y - startPoint.y;
    CGFloat widthSquared = powf(width, 2.0);
    CGFloat heightSquared = powf(height, 2.0);
    CGFloat widthSquaredPlusHeightSquared = widthSquared + heightSquared;
    
    if (widthSquaredPlusHeightSquared > 0) {
        CGFloat lengthMultiplier = sqrtf(distanceSquared / (widthSquared + heightSquared));
        CGFloat newX = startPoint.x + (lengthMultiplier * width);
        CGFloat newY = startPoint.y + (lengthMultiplier * height);
        endPoint = CGPointMake(newX, newY);
    }
    
    return endPoint;
}

CGPoint LIFEEndpointAdjustedForMinimumDistance(CGPoint startPoint, CGPoint endPoint, CGFloat minimumDistance) {
    CGFloat arrowLength = LIFECGPointDistance(startPoint, endPoint);
    
    if (arrowLength < minimumDistance) {
        CGFloat minimumArrowLengthSquared = powf(minimumDistance, 2.0);
        CGFloat width = endPoint.x - startPoint.x;
        CGFloat height = endPoint.y - startPoint.y;
        CGFloat widthSquared = powf(width, 2.0);
        CGFloat heightSquared = powf(height, 2.0);
        CGFloat widthSquaredPlusHeightSquared = widthSquared + heightSquared;
        
        if (widthSquaredPlusHeightSquared > 0) {
            CGFloat lengthMultiplier = sqrtf(minimumArrowLengthSquared / (widthSquared + heightSquared));
            CGFloat newX = startPoint.x + (lengthMultiplier * width);
            CGFloat newY = startPoint.y + (lengthMultiplier * height);
            endPoint = CGPointMake(newX, newY);
        }
    }
    
    return endPoint;
}

CGVector LIFEEndVectorAdjustedForMinimumDistance(CGVector startVector, CGVector endVector, CGSize boundsSize, CGFloat minimumDistance) {
    CGPoint startPoint = LIFEPointFromVectorAndSize(startVector, boundsSize);
    CGPoint endPoint = LIFEPointFromVectorAndSize(endVector, boundsSize);
    
    CGPoint adjustedEndPoint = LIFEEndpointAdjustedForMinimumDistance(startPoint, endPoint, minimumDistance);
    
    CGVector adjustedEndVector = CGVectorMake(adjustedEndPoint.x / boundsSize.width, adjustedEndPoint.y / boundsSize.height);
    return adjustedEndVector;
}

#pragma mark - CGPoint <-> CGVector conversions

CGPoint LIFEPointFromVectorAndSize(CGVector vector, CGSize size) {
    return CGPointMake(vector.dx * size.width, vector.dy * size.height);
}

CGVector LIFEVectorFromPointAndSize(CGPoint point, CGSize size) {
    return CGVectorMake(point.x / size.width, point.y / size.height);
}

CGPoint LIFECGPointApplyRotation(CGPoint pointToRotate, CGPoint anchor, CGFloat angleInRadians)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, anchor.x, anchor.y);
    transform = CGAffineTransformRotate(transform, angleInRadians);
    transform = CGAffineTransformTranslate(transform, -anchor.x, -anchor.y); // Translate back
    return CGPointApplyAffineTransform(pointToRotate, transform);
}

CGPoint LIFECGPointApplyScale(CGPoint pointToScale, CGPoint anchor, CGFloat scaleAmount)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, anchor.x, anchor.y);
    transform = CGAffineTransformScale(transform, scaleAmount, scaleAmount);
    transform = CGAffineTransformTranslate(transform, -anchor.x, -anchor.y);
    return CGPointApplyAffineTransform(pointToScale, transform);
}
