//
//  LIFEDependencyLoader.m
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

#import "LIFEDependencyLoader.h"
#import "LIFEMacros.h"
#import <dlfcn.h>

void LIFELoadAVKit() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *frameworkHandle = dlopen("/System/Library/Frameworks/AVKit.framework/AVKit", RTLD_LAZY | RTLD_GLOBAL);
        
        if (frameworkHandle) {
        } else {
            LIFELogExtWarn(@"Buglife warning: Your app must link AVKit.framework to enable video playback in in the bug reporter UI.");
        }
    });
}

void LIFELoadPhotosFramework() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *frameworkHandle = dlopen("/System/Library/Frameworks/Photos.framework/Photos", RTLD_LAZY | RTLD_GLOBAL);
        
        if (frameworkHandle) {
        } else {
            LIFELogExtWarn(@"Buglife warning: Your app must link Photos.framework to enable photo attachments in bug reports.");
        }
    });
}
