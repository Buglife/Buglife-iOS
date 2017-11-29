//
//  LIFECategories.h
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


#import <Foundation/Foundation.h>

@interface LIFECategories : NSObject

+ (void)loadCategories;

@end

// Categories need to be explicitly loaded at runtime
// in case the host application isn't compiled using the -ObjC flag
#define LIFE_CATEGORY_METHOD_IMPL(className) + (void)life_loadCategory_ ## className ## LIFEAdditions { }
#define LIFE_CATEGORY_FUNCTION_DECL(className) void LIFELoadCategoryFor_ ## className ## LIFEAdditions(void);
#define LIFE_CATEGORY_FUNCTION_IMPL(className) void LIFELoadCategoryFor_ ## className ## LIFEAdditions(void) { [className life_loadCategory_ ## className ## LIFEAdditions]; }
