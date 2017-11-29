//
//  LIFEReportViewControllerDelegate.h
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

@class LIFEReport;
@class LIFEReportBuilder;
@class LIFEReportTableViewController;

@protocol LIFEReportViewControllerDelegate <NSObject>

- (BOOL)reportViewControllerShouldSubmitSynchronously:(nonnull LIFEReportTableViewController *)reportViewController;

- (void)reportViewControllerDidCancel:(nonnull LIFEReportTableViewController *)reportViewController;

// The reportViewController should call this when it's done
// setting all user-configurable fields on the report builder
- (void)reportViewController:(nonnull LIFEReportTableViewController *)reportViewController shouldCompleteReportBuilder:(nonnull LIFEReportBuilder *)reportBuilder completion:(void (^_Nullable)(BOOL finished))completion;

@end
