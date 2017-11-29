//
//  LIFEWhatHappenedView.h
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

@class LIFEWhatHappenedTextView;

@protocol LIFEWhatHappenedTextViewDelegate <NSObject>

- (void)whatHappenedTextViewDidChange:(nonnull LIFEWhatHappenedTextView *)textView;

@end

@class LIFEInputField;
@class LIFEWhatHappenedTableViewCell;

@interface LIFEWhatHappenedTextView : UIView

// this is named `lifeDelegate` so as to not conflict with UITextView.delegate
@property (nonatomic, weak, nullable) id <LIFEWhatHappenedTextViewDelegate> lifeDelegate;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *placeholderText;
@property (nonatomic, copy, nullable) LIFEInputField *inputField;

- (nullable LIFEWhatHappenedTableViewCell *)tableViewCell;

@end





@interface LIFEWhatHappenedTableViewCell : UITableViewCell

@property (nonatomic, readonly, nonnull) LIFEWhatHappenedTextView *textView;

+ (nonnull NSString *)defaultIdentifier;
+ (CGFloat)heightWithText:(nullable NSString *)text boundsWidth:(CGFloat)boundsWidth;

@end







@interface LIFEWhatHappenedHeightCache : NSObject

// Determines the height given the text & table view bounds;
// if the height has changed, then the table view is updated
- (void)setHeightWithText:(nullable NSString *)text inTableView:(nonnull UITableView *)tableView;

@end
