//
//  LIFEDependencyLoader.h
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
#import "LIFEAVFoundation.h"

/**
 *  We dynamically load frameworks at runtime. Why? Because for developers manually
 *  installing the Buglife SDK, adding necessary frameworks is a PITA. Dynamically
 *  loading frameworks at runtime allows us to minimize dependencies, and to
 *  be ridiculously easy to install :)
 *  This also gives us the flexibility to easily target other platforms (i.e. watchOS)
 *  in the future.
 *
 *  LIFELoad* functions should only be called *as needed*, rather than all at once.
 *  This is to minimize the performance impact of loading individual frameworks.
 */
@interface LIFEDependencyLoader : NSObject
@end

void LIFELoadAVKit(void);
void LIFELoadPhotosFramework(void);
