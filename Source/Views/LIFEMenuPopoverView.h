//
//  LIFEMenuPopoverView.h
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

@class LIFEMenuPopoverView;

@protocol LIFEMenuPopoverViewDelegate <NSObject>
@optional
- (void)popoverView:(LIFEMenuPopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index;
- (void)popoverViewDidDismiss:(LIFEMenuPopoverView *)popoverView;

@end

@interface LIFEMenuPopoverView : UIView

@property (nonatomic, copy) UIColor *popOverBackgroundColor;
@property (nonatomic, copy) UIColor *popOverHighlightedColor;
@property (nonatomic, copy) UIColor *popOverSelectedColor;
@property (nonatomic, copy) UIColor *popOverDividerColor;
@property (nonatomic, copy) UIColor *popOverBorderColor;
@property (nonatomic, copy) UIColor *popOverTextColor;
@property (nonatomic, copy) UIColor *popOverHighlightedTextColor;
@property (nonatomic, copy) UIColor *popOverSelectedTextColor;

@property (weak, nonatomic) id<LIFEMenuPopoverViewDelegate> delegate;

//- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view withStrings:(NSArray *)stringArray;
//- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view withStrings:(NSArray *)stringArray selectedIndex:(NSInteger)selectedIndex;

// My stuff

- (void)presentPopoverFromBezierPath:(UIBezierPath *)path inView:(UIView *)view withStrings:(NSArray *)stringArray;

// Returns the delete menu popover's arrowhead point in the screen coordinates.
- (CGPoint)arrowPoint;

@end
