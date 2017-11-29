//
//  LIFELocalizedStringProvider.h
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

#import <Foundation/Foundation.h>
#import "Buglife+LocalizedStrings.h"

/**
 Translation process for the following strings:
 1. Go to http://regexr.com/
 2. Copy all the lines of code defining strings from LIFELocalizedStrings.h, paste into regex box
 3. Use regex expression:
    LIFEStringKey LIFEStringKey_(\w+) = @\"(.+)\";
 4. Click "Replace", and add the following replace expression:
    "$1" = "$2";
 5. Send to tethras.com
 6. When tethras.com returns translations, download translated Localizable.strings & copy into regexr.com
 7. Use regex expression:
    \"(\w+)\" = \"(.*)\";
 8. Replace w/ following expression:
    $1 : @"$2”,
 */

LIFEStringKey LIFEStringKey_PoweredByBuglife = @"Powered by Buglife";

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)

#define LIFELocalizedString(key) [NSBundle.mainBundle localizedStringForKey:NSStringize(key) value:([LIFELocalizedStringProvider sharedInstance].isDebugModeEnabled ? NSStringize(key) : [[LIFELocalizedStringProvider sharedInstance] stringForKey:key]) table:nil]

@interface LIFELocalizedStringProvider : NSObject

+ (nonnull instancetype)sharedInstance;
- (nullable NSString *)stringForKey:(nonnull NSString *)key;
- (BOOL)isEnglish;

// Set this to YES to make -stringForKey: return the keys themselves,
// when the hot app hasn't specified a value for that key
@property (nonatomic, getter=isDebugModeEnabled) BOOL debugModeEnabled;

@end
