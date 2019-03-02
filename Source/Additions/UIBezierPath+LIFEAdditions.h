//
//  UIBezierPath+LIFEAdditions.h
//  Pods
//
//  Created by David Schukin on 12/3/15.
//
//

#import <UIKit/UIKit.h>

@interface LIFEUIBezierPath :NSObject

#pragma mark - Dragonfly

+ (UIBezierPath *)life_dragonFlyBezierPath;
+ (CGSize)life_dragonFlyBezierPathSize;

#pragma mark - Pen

+ (UIBezierPath *)life_penBezierPathWithSize:(CGSize)size;

#pragma mark - Everything else

+ (UIBezierPath *)life_bezierPathWithArrowFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
+ (UIBezierPath *)life_bezierPathWithArrowFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint minTailWidth:(CGFloat)minTailWidth maxTailWith:(CGFloat)maxTailWidth headWidth:(CGFloat)headWidth headLength:(CGFloat)headLength;
+ (UIBezierPath *)life_bezierPathForDiscloserIndicator;

#pragma mark - Helper methods

@end

void LIFELoadCategoryFor_UIBezierPathLIFEAdditions(void);

@interface UIBezierPath (LIFEAdditions)

- (NSArray<NSValue *> *)life_controlPoints;

@end

CGFloat LIFECGPointDistance(CGPoint p1, CGPoint p2);
CGFloat LIFETailWidthForArrowLength(CGFloat arrowLength);
CGFloat LIFEHeadLengthForArrowLength(CGFloat arrowLength);
CGFloat LIFEHeadWidthForArrowWithHeadLength(CGFloat headLength);
CGFloat LIFEMinTailWidthForArrowWithHeadWidth(CGFloat arrowHeadWidth);
CGFloat LIFEMaxTailWidthForArrowWithHeadWidth(CGFloat arrowHeadWidth);
