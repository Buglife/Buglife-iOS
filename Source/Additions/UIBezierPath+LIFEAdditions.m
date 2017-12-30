//
//  UIBezierPath+LIFEAdditions.m
//
//  Created by David Schukin on 12/3/15.
//
//

#import "UIBezierPath+LIFEAdditions.h"

static NSString * const kDragonflyBezierPathDataString = @"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";

@implementation LIFEUIBezierPath

+ (UIBezierPath *)life_dragonFlyBezierPath
{
    static UIBezierPath *sBezierPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *data = [[NSData alloc] initWithBase64EncodedString:kDragonflyBezierPathDataString options:0];
        sBezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    });
    return [sBezierPath copy]; // return a copy because UIBezierPath is mutable
}

+ (CGSize)life_dragonFlyBezierPathSize
{
    return CGSizeMake(28, 22);
}

+ (UIBezierPath *)life_bezierPathWithArrowFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    CGFloat arrowLength = LIFECGPointDistance(startPoint, endPoint);
    CGFloat headLength = LIFEHeadLengthForArrowLength(arrowLength);
    CGFloat headWidth = LIFEHeadWidthForArrowWithHeadLength(arrowLength);
    CGFloat minTailWidth = LIFEMinTailWidthForArrowWithHeadWidth(headWidth);
    CGFloat maxTailWidth = LIFEMaxTailWidthForArrowWithHeadWidth(headWidth);
    
    return [self life_bezierPathWithArrowFromPoint:startPoint toPoint:endPoint minTailWidth:minTailWidth maxTailWith:maxTailWidth headWidth:headWidth headLength:headLength];
}

+ (UIBezierPath *)life_bezierPathWithArrowFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint minTailWidth:(CGFloat)minTailWidth maxTailWith:(CGFloat)maxTailWidth headWidth:(CGFloat)headWidth headLength:(CGFloat)headLength
{
    CGFloat length = hypotf((float)endPoint.x - (float)startPoint.x, (float)endPoint.y - (float)startPoint.y);
    
    if (length < 0.1) {
        return nil;
    }
    
    CGFloat tailLength = length - headLength;
    CGFloat tailCurve = (minTailWidth / 2);
    CGFloat tailSqueeze = (tailCurve * 2);
    CGFloat tailPunch = headLength * 0.1;
    
    CGPoint points[7] = {
        CGPointMake(0, minTailWidth / 2),
        CGPointMake(tailLength + tailPunch, maxTailWidth / 2),
        CGPointMake(tailLength, headWidth / 2),
        CGPointMake(length, 0),
        CGPointMake(tailLength, -headWidth / 2),
        CGPointMake(tailLength + tailPunch, -maxTailWidth / 2),
        CGPointMake(0, -minTailWidth / 2)
    };
    CGFloat cosine = (endPoint.x - startPoint.x) / length;
    CGFloat sine = (endPoint.y - startPoint.y) / length;
    CGAffineTransform transform = (CGAffineTransform){ cosine, sine, -sine, cosine, startPoint.x, startPoint.y };

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:points[0]];
    [path addCurveToPoint:points[1] controlPoint1:points[0] controlPoint2:CGPointMake(points[1].x, points[1].y - tailSqueeze)];
    [path addLineToPoint:points[2]];
    [path addLineToPoint:points[3]];
    [path addLineToPoint:points[4]];
    [path addLineToPoint:points[5]];
    [path addCurveToPoint:points[6] controlPoint1:CGPointMake(points[5].x, points[5].y + tailSqueeze) controlPoint2:points[6]];   // Curves the butt of the tail
    [path addCurveToPoint:points[0] controlPoint1:CGPointMake(-tailCurve, points[6].y) controlPoint2:CGPointMake(-tailCurve, points[0].y)]; // Curves the butt of the tail
    [path closePath];
    
    [path applyTransform:transform];
    
    return path;
}

+ (UIBezierPath *)life_bezierPathForDiscloserIndicator
{
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
//    [bezierPath moveToPoint: CGPointMake(0, 3)];
//    [bezierPath addLineToPoint: CGPointMake(3, 0)];
//    [bezierPath addLineToPoint: CGPointMake(16, 13)];
//    [bezierPath addLineToPoint: CGPointMake(3, 26)];
//    [bezierPath addLineToPoint: CGPointMake(0, 23)];
//    [bezierPath addLineToPoint: CGPointMake(11, 13)];
    
    [bezierPath moveToPoint: CGPointMake(0, 1.5)];
    [bezierPath addLineToPoint: CGPointMake(1.5, 0)];
    [bezierPath addLineToPoint: CGPointMake(8, 6.5)];
    [bezierPath addLineToPoint: CGPointMake(1.5, 13)];
    [bezierPath addLineToPoint: CGPointMake(0, 11.5)];
    [bezierPath addLineToPoint: CGPointMake(5.5, 6.5)];
    
    [bezierPath closePath];
    return bezierPath;
}

@end

@implementation UIBezierPath (LIFEAdditions)

+ (void)life_loadCategory_UIBezierPathLIFEAdditions { }

- (NSArray<NSValue *> *)life_controlPoints
{
    NSMutableArray<NSValue *> *points = [[NSMutableArray alloc] init];
    CGPathRef cgPath = self.CGPath;
    CGPathApply(cgPath, (__bridge void *)(points), LIFECGPathApplierFunc);
    return [NSArray arrayWithArray:points];
}

void LIFECGPathApplierFunc(void *info, const CGPathElement *element) {
    NSMutableArray<NSValue *> *bezierPoints = (__bridge NSMutableArray *)info;
    
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
            
        case kCGPathElementAddLineToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
            
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            break;
            
        case kCGPathElementAddCurveToPoint: // contains 3 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[2]]];
            break;
            
        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
}

@end

void LIFELoadCategoryFor_UIBezierPathLIFEAdditions() {
    [UIBezierPath life_loadCategory_UIBezierPathLIFEAdditions];
}

inline CGFloat LIFETailWidthForArrowLength(CGFloat arrowLength) {
    return (MAX(4.0f, arrowLength * 0.07f));
}

inline CGFloat LIFEMaxTailWidthForArrowWithHeadWidth(CGFloat arrowHeadWidth) {
    return arrowHeadWidth * 0.45;
}

inline CGFloat LIFEMinTailWidthForArrowWithHeadWidth(CGFloat arrowHeadWidth) {
    return arrowHeadWidth * 0.1;
}

inline CGFloat LIFEHeadLengthForArrowLength(CGFloat arrowLength) {
    return (MAX(arrowLength / 3.0f, 10.0f));
}

inline CGFloat LIFEHeadWidthForArrowWithHeadLength(CGFloat headLength) {
    return (headLength * 0.35f);
}
