//
//  UIImage+LIFEAdditions.m
//  Copyright (C) 2015-2018 Buglife, Inc.
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

#import "UIImage+LIFEAdditions.h"
#import "UIBezierPath+LIFEAdditions.h"
#import "UIColor+LIFEAdditions.h"
#import "LIFEMacros.h"
#import "LIFEImageFormat.h"
#import <Accelerate/Accelerate.h>
#import <float.h>

#pragma mark - Constants

const CGFloat LIFEDefaultBlurAmount = 0.5;
static const CGInterpolationQuality kLIFEInterpolationQuality = kCGInterpolationHigh;

#pragma mark - Forward declarations

NSData * _LIFEUIImageRepresentationScaledForMaximumFilesize(LIFEImageFormat imageFormat, UIImage *originalImage, NSUInteger maximumFilesize, CGFloat compressionQuality);

#pragma mark - C functions

NSData * LIFEUIImagePNGRepresentationScaledForMaximumFilesize(UIImage *originalImage, NSUInteger maximumFilesize)
{
    CGFloat compressionQuality = 0; // this value is ignored for PNGs
    return _LIFEUIImageRepresentationScaledForMaximumFilesize(LIFEImageFormatPNG, originalImage, maximumFilesize, compressionQuality);
}

NSData * LIFEUIImageJPEGRepresentationScaledForMaximumFilesize(UIImage *originalImage, NSUInteger maximumFilesize, CGFloat compressionQuality)
{
    return _LIFEUIImageRepresentationScaledForMaximumFilesize(LIFEImageFormatJPEG, originalImage, maximumFilesize, compressionQuality);
}

NSData * _LIFEUIImageRepresentationScaledForMaximumFilesize(LIFEImageFormat imageFormat, UIImage *originalImage, NSUInteger maximumFilesize, CGFloat compressionQuality)
{
    
    UIImage *resizedImage = originalImage;
    NSData *result = LIFEImageRepresentationWithImageFormat(imageFormat, resizedImage, compressionQuality);
    CGFloat currentScaleFactor = 1;
    NSUInteger currentFilesize = result.length;
    NSUInteger stepNumber = 0;
    
    while (currentFilesize > maximumFilesize) {
        currentScaleFactor *= 0.85;
        resizedImage = [originalImage life_resizedImageWithScaleFactor:currentScaleFactor interpolationQuality:kLIFEInterpolationQuality];
        result = LIFEImageRepresentationWithImageFormat(imageFormat, resizedImage, compressionQuality);
        currentFilesize = result.length;
        stepNumber += 1;
        
        LIFELogIntDebug(@"Buglife - [%@] image size: %@ length: %@", @(stepNumber), NSStringFromCGSize(resizedImage.size), @(result.length));
    }
    
    LIFELogIntDebug(@"Buglife - steps required: %@", @(stepNumber));
    
    return result;
}

@implementation UIImage (LIFEAdditions)

+ (void)life_loadCategory_UIImageLIFEAdditions { }

- (UIImage *)life_resizedImageWithScaleFactor:(CGFloat)scaleFactor interpolationQuality:(CGInterpolationQuality)quality
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    CGRect scaledRect = CGRectApplyAffineTransform(rect, transform);
    scaledRect = CGRectIntegral(scaledRect);
    CGSize size = scaledRect.size;
    return [self life_resizedImage:size interpolationQuality:quality];
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)life_resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self life_resizedImage:newSize
                    transform:[self life_transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

+ (UIImage *)life_dragonflyIconWithColor:(UIColor *)color
{
    CGSize size = [LIFEUIBezierPath life_dragonFlyBezierPathSize];
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    UIBezierPath *path = [LIFEUIBezierPath life_dragonFlyBezierPath];
    [color setFill];
    [path fill];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

#pragma mark - Private methods

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)life_resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)life_transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;

        default:
            ; // nothing to do
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        
        default:
            ; // nothing to do
    }
    
    return transform;
}

@end

@implementation LIFEUIImage

+ (CGFloat)life_aspectRatio:(UIImage *)image
{
    if (image.size.height > 0) {
        return image.size.width / image.size.height;
    } else {
        return 0;
    }
}

+ (UIImage *)image:(UIImage *)image scaledToSize:(CGSize)size
{
    NSAssert(!CGSizeEqualToSize(size, CGSizeZero), @"Image must have a non-zero size!");
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage *)image:(UIImage *)image croppedToRect:(CGRect)rect
{
    CGFloat scale = image.scale;
    if (scale > 1.0f) rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

+ (UIImage *)rotateImage:(UIImage *)sourceImage toOrientation:(UIImageOrientation)targetOrientation
{
    // No-op if the orientation is already correct
    if (targetOrientation == UIImageOrientationUp) return sourceImage;
    
    CGSize sourceSize = CGSizeMake(sourceImage.size.height, sourceImage.size.width);
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (targetOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, sourceSize.width, sourceSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, sourceSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, sourceSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (targetOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, sourceSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, sourceSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    UIGraphicsBeginImageContextWithOptions(sourceSize, YES, sourceImage.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextConcatCTM(ctx, transform);
    switch (targetOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            [sourceImage drawInRect:CGRectMake(0,0,sourceSize.height,sourceSize.width)];
            break;
            
        default:
            [sourceImage drawInRect:CGRectMake(0,0,sourceSize.height,sourceSize.width)];
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - Icons

+ (UIImage *)life_arrowToolbarIcon
{
    CGSize size = CGSizeMake(22, 22);
    UIColor *strokeColor = [UIColor blackColor];
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGPoint startPoint = CGPointMake(size.width - 2, 2);
    CGPoint endPoint = CGPointMake(1, size.height - 1);
    
    UIBezierPath *path = [LIFEUIBezierPath life_bezierPathWithArrowFromPoint:startPoint toPoint:endPoint];
    path.lineWidth = 1;
    [strokeColor setStroke];
    [path stroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    result.accessibilityLabel = LIFELocalizedString(LIFEStringKey_Arrow);
    
    return [result imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}


+ (UIImage *)life_loupeIcon
{
    CGFloat lineWidth = 2;
    CGRect circleRect = CGRectMake(0, 0, 22, 22);
    CGRect holeRect = CGRectInset(circleRect, lineWidth, lineWidth);
    UIColor *strokeColor = [UIColor blackColor];
    UIGraphicsBeginImageContextWithOptions(circleRect.size, NO, 0);
    
    {
        // Outer most stuff
        UIBezierPath* loupeFillPath = [UIBezierPath bezierPath];
        [loupeFillPath moveToPoint: CGPointMake(22, 11)];
        [loupeFillPath addCurveToPoint: CGPointMake(22, 22) controlPoint1: CGPointMake(22, 13.61) controlPoint2: CGPointMake(22, 22)];
        [loupeFillPath addCurveToPoint: CGPointMake(11, 22) controlPoint1: CGPointMake(22, 22) controlPoint2: CGPointMake(14.47, 22)];
        [loupeFillPath addCurveToPoint: CGPointMake(0, 11) controlPoint1: CGPointMake(4.92, 22) controlPoint2: CGPointMake(0, 17.08)];
        [loupeFillPath addCurveToPoint: CGPointMake(11, 0) controlPoint1: CGPointMake(0, 4.92) controlPoint2: CGPointMake(4.92, 0)];
        [loupeFillPath addCurveToPoint: CGPointMake(22, 11) controlPoint1: CGPointMake(17.08, 0) controlPoint2: CGPointMake(22, 4.92)];
        [loupeFillPath closePath];
        
        // Create a hole in it
        UIBezierPath *holePath = [UIBezierPath bezierPathWithOvalInRect:holeRect];
        
        // Fill in the outer part with a hole
        [loupeFillPath appendPath:holePath];
        loupeFillPath.usesEvenOddFillRule = YES;
        [strokeColor setFill];
        [loupeFillPath fill];
    }
    
    {
        CGRect shineRect = CGRectInset(holeRect, 2, 2);
        CGRect shineMaskRect = CGRectOffset(shineRect, 2, 2);
        
        UIBezierPath *shinePath = [UIBezierPath bezierPathWithOvalInRect:shineRect];
        UIBezierPath *shineMaskPath = [UIBezierPath bezierPathWithOvalInRect:shineMaskRect];
        
        [shineMaskPath appendPath:shinePath];
        shineMaskPath.usesEvenOddFillRule = YES;
        
        CGContextSaveGState(UIGraphicsGetCurrentContext()); {
            [shineMaskPath addClip];
            UIColor *shineColor = [strokeColor colorWithAlphaComponent:0.25];
            [shineColor setFill];
            [shinePath fill];
        } CGContextRestoreGState(UIGraphicsGetCurrentContext());
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    result.accessibilityLabel = LIFELocalizedString(LIFEStringKey_Loupe);
    
    return [result imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
}

+ (UIImage *)life_pixelateIcon
{
    UIColor *strokeColor = [UIColor blackColor];
    CGFloat lineWidth = 1;
    CGFloat tileWidth = 4;
    NSUInteger tileCount = 4;
    CGFloat iconWidth = (tileCount * tileWidth) + lineWidth;
    CGSize size = CGSizeMake(iconWidth, iconWidth);
    CGFloat origin = (lineWidth / 2.0);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    for (NSUInteger i = 0; i < tileCount; i++) {
        for (NSUInteger j = 0; j < tileCount; j++) {
            CGFloat x = (i * tileWidth) + origin;
            CGFloat y = (j * tileWidth) + origin;
            CGRect rect = CGRectMake(x, y, tileWidth, tileWidth);
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
            [strokeColor setStroke];
            path.lineWidth = lineWidth;
            [path stroke];
            
            NSUInteger r = arc4random_uniform(3);
            CGFloat fillAlpha = (r * 0.33);
            
            UIColor *fillColor = [strokeColor colorWithAlphaComponent:fillAlpha];
            [fillColor setFill];
            [path fill];
        }
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    result.accessibilityLabel = LIFELocalizedString(LIFEStringKey_Blur);
    
    return [result imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
}

// trash can constants
static const CGFloat kDivotSpacing = 3;
static const CGFloat kDivotWidth = 2;
static const CGFloat kCanHeight = 22;

// handle constants
static const CGFloat kHandleHeight = 2;
static const CGFloat kHandleWidth = 6;

// lid constants
static const CGFloat kLidHeight = 3;
static const CGFloat kLidOffsetX = 2;
static const CGFloat kLidSpacing = 1;

+ (UIImage *)life_trashCanLidImageWithColor:(UIColor *)color
{
    CGFloat lidCornerRadius = kLidHeight * 4;
    
    // can constants
    CGFloat canWidth = (kDivotSpacing * 4) + (kDivotWidth * 3);
    
    // rects
    CGFloat lidWidth = canWidth + (2 * kLidOffsetX);
    CGRect lidRect = CGRectMake(0, kHandleHeight + kLidSpacing, lidWidth, kLidHeight);
    CGRect handleRect = CGRectMake((lidWidth - kHandleWidth) / 2, 0, kHandleWidth, kHandleHeight);
    
    CGFloat width = lidWidth;
    CGFloat height = CGRectGetMaxY(lidRect);
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    // lid
    UIBezierPath *lidPath = [UIBezierPath bezierPathWithRoundedRect:lidRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(lidCornerRadius, lidCornerRadius)];
    [color setFill];
    [lidPath fill];
    
    // handle
    UIBezierPath *handlePath = [UIBezierPath bezierPathWithRoundedRect:handleRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(lidCornerRadius, lidCornerRadius)];
    [handlePath fill];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage *)life_trashCanCanImageWithColor:(UIColor *)color
{
    // can constants
    CGFloat canWidth = (kDivotSpacing * 4) + (kDivotWidth * 3);
    CGFloat canCornerRadius = kCanHeight * 0.1;
    
    // rects
    CGPoint canOffset = CGPointZero;
    CGRect canRect = CGRectMake(canOffset.x, canOffset.y, canWidth, kCanHeight);
    
    CGFloat width = canWidth;
    CGFloat height = CGRectGetMaxY(canRect);
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    // can
    UIBezierPath *canPath = [UIBezierPath bezierPathWithRoundedRect:canRect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(canCornerRadius, canCornerRadius)];
    canPath.usesEvenOddFillRule = YES;
    
    // divots
    CGRect divot1rect = CGRectMake(canOffset.x + kDivotSpacing, canOffset.y + kDivotSpacing, kDivotWidth, kCanHeight - (2 * kDivotSpacing));
    UIBezierPath *divot1path = [UIBezierPath bezierPathWithRoundedRect:divot1rect cornerRadius:canCornerRadius];
    [canPath appendPath:divot1path];
    
    CGRect divot2rect = CGRectOffset(divot1rect, CGRectGetWidth(divot1rect) + kDivotSpacing, 0);
    UIBezierPath *divot2path = [UIBezierPath bezierPathWithRoundedRect:divot2rect cornerRadius:canCornerRadius];
    [canPath appendPath:divot2path];
    
    CGRect divot3rect = CGRectOffset(divot2rect, CGRectGetWidth(divot2rect) + kDivotSpacing, 0);
    UIBezierPath *divot3path = [UIBezierPath bezierPathWithRoundedRect:divot3rect cornerRadius:canCornerRadius];
    [canPath appendPath:divot3path];
    
    [color setFill];
    [canPath fill];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

#pragma mark - Pixelate

+ (UIImage *)image:(UIImage *)sourceImage pixelatedImageWithAmount:(CGFloat)amount
{
    NSParameterAssert(amount >= 0 && amount <= 1);
    CGFloat inputScale = 60 * amount;
    UIColor *backgroundFillColor = [UIColor blackColor];
    
    
    CIFilter *pixelateFilter = [CIFilter filterWithName:@"CIPixellate"];
    [pixelateFilter setDefaults];
    [pixelateFilter setValue:[CIImage imageWithCGImage:sourceImage.CGImage] forKey:kCIInputImageKey];
    [pixelateFilter setValue:@(inputScale) forKey:@"inputScale"];
    //    [pixelateFilter setValue:vector forKey:@"inputCenter"];
    CIImage* result = [pixelateFilter valueForKey:kCIOutputImageKey];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect extent = [result extent];
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    
    UIGraphicsBeginImageContextWithOptions(sourceImage.size, YES, [sourceImage scale]);
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ref, 0, sourceImage.size.height);
    CGContextScaleCTM(ref, 1.0, -1.0);
    
    CGContextSetFillColorWithColor(ref, backgroundFillColor.CGColor);
    CGRect drawRect = (CGRect){{0,0},sourceImage.size};
    CGContextFillRect(ref, drawRect);
    CGContextDrawImage(ref, drawRect, cgImage);
    UIImage* filledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *returnImage = filledImage;
    
    CGImageRelease(cgImage);
    
    return returnImage;
}

+ (UIImage *)life_disclosureIndicatorIcon
{
    CGSize size = CGSizeMake(8, 13);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    UIBezierPath *path = [LIFEUIBezierPath life_bezierPathForDiscloserIndicator];
    UIColor *fillColor = [UIColor life_colorWithHexValue:0xc7c7cc];
    [fillColor setFill];
    [path fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Blur

//- (UIImage *)life_applyLightEffect
//{
//    UIColor *tintColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
//    return [self life_applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8f maskImage:nil];
//}
//
//
//- (UIImage *)life_applyExtraLightEffect
//{
//    UIColor *tintColor = [UIColor colorWithWhite:0.97f alpha:0.82f];
//    return [self life_applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8f maskImage:nil];
//}
//
//
//- (UIImage *)life_applyDarkEffect
//{
//    UIColor *tintColor = [UIColor colorWithWhite:0.11f alpha:0.73f];
//    return [self life_applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8f maskImage:nil];
//}
//
//
//- (UIImage *)life_applyTintEffectWithColor:(UIColor *)tintColor
//{
//    const CGFloat EffectColorAlpha = 0.6f;
//    UIColor *effectColor = tintColor;
//    int componentCount = (int) CGColorGetNumberOfComponents(tintColor.CGColor);
//    if (componentCount == 2) {
//        CGFloat b;
//        if ([tintColor getWhite:&b alpha:NULL]) {
//            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
//        }
//    }
//    else {
//        CGFloat r, g, b;
//        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
//            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
//        }
//    }
//    return [self life_applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
//}
//
//
//- (UIImage *)life_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
//{
//    // Check pre-conditions.
//    if (self.size.width < 1 || self.size.height < 1) {
//        LIFELogIntError (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
//        return nil;
//    }
//    if (!self.CGImage) {
//        LIFELogIntError (@"*** error: image must be backed by a CGImage: %@", self);
//        return nil;
//    }
//    if (maskImage && !maskImage.CGImage) {
//        LIFELogIntError (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
//        return nil;
//    }
//    
//    CGRect imageRect = { CGPointZero, self.size };
//    UIImage *effectImage = self;
//    
//    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
//    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
//    if (hasBlur || hasSaturationChange) {
//        UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
//        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
//        CGContextScaleCTM(effectInContext, 1.0, -1.0);
//        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
//        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
//        
//        vImage_Buffer effectInBuffer;
//        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
//        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
//        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
//        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
//        
//        UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
//        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
//        vImage_Buffer effectOutBuffer;
//        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
//        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
//        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
//        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
//        
//        if (hasBlur) {
//            // A description of how to compute the box kernel width from the Gaussian
//            // radius (aka standard deviation) appears in the SVG spec:
//            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
//            //
//            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
//            // successive box-blurs build a piece-wise quadratic convolution kernel, which
//            // approximates the Gaussian kernel to within roughly 3%.
//            //
//            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
//            //
//            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
//            //
//            CGFloat inputRadius = blurRadius * UIScreen.mainScreen.scale;
//            uint32_t radius = (uint32_t) floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
//            if (radius % 2 != 1) {
//                radius += 1; // force radius to be odd so that the three box-blur methodology works.
//            }
//            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
//            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
//            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
//        }
//        BOOL effectImageBuffersAreSwapped = NO;
//        if (hasSaturationChange) {
//            CGFloat s = saturationDeltaFactor;
//            CGFloat floatingPointSaturationMatrix[] = {
//                0.0722f + 0.9278f * s,  0.0722f - 0.0722f * s,  0.0722f - 0.0722f * s,  0,
//                0.7152f - 0.7152f * s,  0.7152f + 0.2848f * s,  0.7152f - 0.7152f * s,  0,
//                0.2126f - 0.2126f * s,  0.2126f - 0.2126f * s,  0.2126f + 0.7873f * s,  0,
//                0,                    0,                    0,  1,
//            };
//            const int32_t divisor = 256;
//            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
//            int16_t saturationMatrix[matrixSize];
//            for (NSUInteger i = 0; i < matrixSize; ++i) {
//                saturationMatrix[i] = (int16_t)roundf((float) floatingPointSaturationMatrix[i] * divisor);
//            }
//            if (hasBlur) {
//                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
//                effectImageBuffersAreSwapped = YES;
//            }
//            else {
//                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
//            }
//        }
//        if (!effectImageBuffersAreSwapped)
//            effectImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        if (effectImageBuffersAreSwapped)
//            effectImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    
//    // Set up output context.
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
//    CGContextRef outputContext = UIGraphicsGetCurrentContext();
//    CGContextScaleCTM(outputContext, 1.0, -1.0);
//    CGContextTranslateCTM(outputContext, 0, -self.size.height);
//    
//    // Draw base image.
//    CGContextDrawImage(outputContext, imageRect, self.CGImage);
//    
//    // Draw effect image.
//    if (hasBlur) {
//        CGContextSaveGState(outputContext);
//        if (maskImage) {
//            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
//        }
//        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
//        CGContextRestoreGState(outputContext);
//    }
//    
//    // Add in color tint.
//    if (tintColor) {
//        CGContextSaveGState(outputContext);
//        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
//        CGContextFillRect(outputContext, imageRect);
//        CGContextRestoreGState(outputContext);
//    }
//    
//    // Output image is ready.
//    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return outputImage;
//}

+ (nonnull UIImage *)life_resizableRoundedRectWithHorizontalInset:(CGFloat)insetX
{
    CGFloat strokeWidth = 1;
    CGFloat cornerRadius = 10;
    CGSize size = CGSizeMake(200, 200);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    rect = CGRectInset(rect, insetX, 0);
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: cornerRadius];
    [UIColor.whiteColor setFill];
    [rectanglePath fill];
    [UIColor.lightGrayColor setStroke];
    rectanglePath.lineWidth = strokeWidth;
    [rectanglePath stroke];
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat capInsetY = cornerRadius + strokeWidth;
    CGFloat capInsetX = capInsetY + insetX;
    UIEdgeInsets capInsets = UIEdgeInsetsMake(capInsetY, capInsetX, capInsetY, capInsetX);
    return [outputImage resizableImageWithCapInsets:capInsets];
}

@end

void LIFELoadCategoryFor_UIImageLIFEAdditions() {
    [UIImage life_loadCategory_UIImageLIFEAdditions];
}
