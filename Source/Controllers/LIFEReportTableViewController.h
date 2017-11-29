//
//  LIFEReportTableViewController.h
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

@protocol LIFEReportViewControllerDelegate;
@class LIFEReportBuilder;
@class LIFEScreenshotContext;

@interface LIFEReportTableViewController : UITableViewController

@property (nonatomic, weak, null_unspecified) id<LIFEReportViewControllerDelegate> delegate;

- (nonnull instancetype)initWithReportBuilder:(nonnull LIFEReportBuilder *)reportBuilder context:(nonnull LIFEScreenshotContext *)context NS_DESIGNATED_INITIALIZER;

- (_Null_unspecified instancetype)init NS_UNAVAILABLE;
- (_Null_unspecified instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (_Null_unspecified instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle  *)nibBundleOrNil NS_UNAVAILABLE;
- (_Null_unspecified instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;

- (void)addLastVideoAsAttachment;

@end
