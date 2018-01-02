//
//  LIFEAlertActionView.h
//  Copyright (C) 2018 Buglife, Inc.
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

typedef UIAlertActionStyle LIFEAlertActionStyle;

// This should probably renamed `LIFEAlertActionButton`.
// Only reason I named it *View was because that's how UIKit
// internally names their alert view buttons.
@interface LIFEAlertActionView : UIControl

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title style:(LIFEAlertActionStyle)style;

@end
