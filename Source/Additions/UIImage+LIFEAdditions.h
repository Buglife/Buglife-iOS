//
//  UIImage+LIFEAdditions.h
//  Pods
//
//  Created by David Schukin on 10/20/15.
//
//

#import <UIKit/UIKit.h>

extern const CGFloat LIFEDefaultBlurAmount;

extern NSData * __nullable LIFEUIImagePNGRepresentationScaledForMaximumFilesize(UIImage * __nonnull image, NSUInteger maximumFilesize);
extern NSData * __nullable LIFEUIImageJPEGRepresentationScaledForMaximumFilesize(UIImage *__nonnull originalImage, NSUInteger maximumFilesize, CGFloat compressionQuality);

void LIFELoadCategoryFor_UIImageLIFEAdditions(void);

@interface UIImage (LIFEAdditions)

- (null_unspecified UIImage *)life_resizedImageWithScaleFactor:(CGFloat)scaleFactor interpolationQuality:(CGInterpolationQuality)quality;
- (null_unspecified UIImage *)life_resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;

@end

@interface LIFEUIImage : NSObject

#pragma mark - Helper methods

+ (CGFloat)life_aspectRatio:(nonnull UIImage *)image;
+ (nonnull UIImage *)image:(nonnull UIImage *)image scaledToSize:(CGSize)size;
+ (nonnull UIImage *)image:(nonnull UIImage *)image croppedToRect:(CGRect)rect;
+ (nonnull UIImage *)rotateImage:(nonnull UIImage *)image toOrientation:(UIImageOrientation)orientation;

#pragma mark - Icons

+ (nonnull UIImage *)life_dragonflyIconWithColor:(nonnull UIColor *)color;
+ (nonnull UIImage *)life_arrowToolbarIcon;
+ (nonnull UIImage *)life_loupeIcon;
+ (nonnull UIImage *)life_pixelateIcon;
+ (nonnull UIImage *)life_trashCanLidImageWithColor:(nonnull UIColor *)color;
+ (nonnull UIImage *)life_trashCanCanImageWithColor:(nonnull UIColor *)color;
+ (nonnull UIImage *)life_disclosureIndicatorIcon;

#pragma mark - Blur

+ (nonnull UIImage *)image:(nonnull UIImage *)image pixelatedImageWithAmount:(CGFloat)amount;

@end
