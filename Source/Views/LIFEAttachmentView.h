//
//  LIFEAttachmentView.h
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

@interface LIFEAttachmentView : UIView;

@property (nonatomic, null_unspecified) UIImage *screenshot;

@end






@interface LIFEAttachmentCell : UITableViewCell

+ (CGSize)targetImageSize;
+ (nonnull NSString *)defaultIdentifier;

- (void)setThumbnailImage:(nullable UIImage *)image;
- (void)setTitle:(nonnull NSString *)title;
- (void)setActivityIndicatorViewIsAnimating:(BOOL)animating;

@end





// @deprecated
@interface LIFEAttachmentButton : UIButton

@property (nonatomic, null_unspecified) UIImage *screenshot;
@property (nonatomic) BOOL lifeSelected; // our own custom 'selected' property to mimic the behavior of table view cells
- (void)setLifeSelected:(BOOL)lifeSelected animated:(BOOL)animated;

@end
