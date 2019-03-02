//
//  UIImage+LIFEAdditions.h
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

#import <UIKit/UIKit.h>

extern const CGFloat LIFEDefaultBlurAmount;

extern NSData * __nullable LIFEUIImagePNGRepresentationScaledForMaximumFilesize(UIImage * __nonnull image, NSUInteger maximumFilesize);
extern NSData * __nullable LIFEUIImageJPEGRepresentationScaledForMaximumFilesize(UIImage *__nonnull originalImage, NSUInteger maximumFilesize, CGFloat compressionQuality);

void LIFELoadCategoryFor_UIImageLIFEAdditions(void);

@interface UIImage (LIFEAdditions)

- (null_unspecified instancetype)life_resizedImageWithScaleFactor:(CGFloat)scaleFactor interpolationQuality:(CGInterpolationQuality)quality;
- (null_unspecified instancetype)life_resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
+ (nonnull instancetype)life_dragonflyIconWithColor:(nonnull UIColor *)color;

@end

@interface LIFEUIImage : NSObject

#pragma mark - Helper methods

+ (CGFloat)life_aspectRatio:(nonnull UIImage *)image;
+ (nonnull UIImage *)image:(nonnull UIImage *)image scaledToSize:(CGSize)size;
+ (nonnull UIImage *)image:(nonnull UIImage *)image croppedToRect:(CGRect)rect;
+ (nonnull UIImage *)rotateImage:(nonnull UIImage *)image toOrientation:(UIImageOrientation)orientation;

#pragma mark - Icons

+ (nonnull UIImage *)life_penToolbarIcon;
+ (nonnull UIImage *)life_arrowToolbarIcon;
+ (nonnull UIImage *)life_loupeIcon;
+ (nonnull UIImage *)life_pixelateIcon;
+ (nonnull UIImage *)life_trashCanLidImageWithColor:(nonnull UIColor *)color;
+ (nonnull UIImage *)life_trashCanCanImageWithColor:(nonnull UIColor *)color;
+ (nonnull UIImage *)life_disclosureIndicatorIcon;

#pragma mark - Blur

+ (nonnull UIImage *)image:(nonnull UIImage *)image pixelatedImageWithAmount:(CGFloat)amount;

#pragma mark - Rounded rects

+ (nonnull UIImage *)life_resizableRoundedRectWithHorizontalInset:(CGFloat)insetX;

@end
