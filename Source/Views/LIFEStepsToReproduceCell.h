//
//  LIFEStepsToReproduceCell.h
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

@class LIFEStepsToReproduceCell;
@class LIFEReproStep;

@protocol LIFEStepsToReproduceCellDelegate <NSObject>

- (void)stepsToReproduceCellDidReturn:(nonnull LIFEStepsToReproduceCell *)stepsToReproduceCell;

@end

@interface LIFEStepsToReproduceCell : UITableViewCell

+ (nonnull NSString *)defaultIdentifier;
@property (nonatomic, weak, null_unspecified) id<LIFEStepsToReproduceCellDelegate> delegate;
@property (nullable, nonatomic, strong) LIFEReproStep *reproStep;
- (void)setStepNumber:(NSUInteger)stepNumber;
+ (CGFloat)heightWithReproStep:(nonnull LIFEReproStep *)reproStep boundsWidth:(CGFloat)boundsWidth;

@end
