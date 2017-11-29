//
//  LIFEAVFoundation.m
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

#import "LIFEAVFoundation.h"
#import <dlfcn.h>

typedef typeof(CMTime) LIFECMTime_t;
static LIFECMTime_t *LIFE_kCMTimeZeroAddr;
static LIFECMTime_t *LIFE_kCMTimePositiveInfinityAddr;

typedef typeof(CMTimeRange) LIFECMTimeRange_t;
static LIFECMTimeRange_t *LIFE_kCMTimeRangeZeroAddr;

typedef typeof(CMTimeMake) LIFECMTimeMake_t;
static LIFECMTimeMake_t *LIFECMTimeMakeAddr = 0;

typedef typeof(CMTimeRangeMake) LIFECMTimeRangeMake_t;
static LIFECMTimeRangeMake_t *LIFECMTimeRangeMakeAddr = 0;

CMTime LIFECMTimeZero()
{
    LIFELoadAVFoundation();
    return *LIFE_kCMTimeZeroAddr;
}

CMTime LIFECMTimePositiveInfinity()
{
    LIFELoadAVFoundation();
    return *LIFE_kCMTimePositiveInfinityAddr;
}

CMTimeRange LIFECMTimeRangeZero()
{
    LIFELoadAVFoundation();
    return *LIFE_kCMTimeRangeZeroAddr;
}

CMTime LIFECMTimeMake(int64_t value, int32_t timescale)
{
    LIFELoadAVFoundation();
    
    if (LIFECMTimeMakeAddr) {
        return (*LIFECMTimeMakeAddr)(value, timescale);
    } else {
        return LIFECMTimeZero();
    }
}

CMTimeRange LIFECMTimeRangeMake(CMTime start, CMTime duration)
{
    LIFELoadAVFoundation();
    
    if (LIFECMTimeRangeMakeAddr) {
        return (*LIFECMTimeRangeMakeAddr)(start, duration);
    } else {
        return LIFECMTimeRangeZero();
    }
}

void LIFELoadAVFoundation() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *frameworkHandle = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", RTLD_LAZY | RTLD_GLOBAL);
        
        if (frameworkHandle) {
            LIFE_kCMTimeZeroAddr = dlsym(frameworkHandle, "kCMTimeZero");
            LIFE_kCMTimeRangeZeroAddr = dlsym(frameworkHandle, "kCMTimeRangeZero");
            LIFE_kCMTimePositiveInfinityAddr = dlsym(frameworkHandle, "kCMTimePositiveInfinity");
            LIFECMTimeMakeAddr = (LIFECMTimeMake_t *)dlsym(frameworkHandle, "CMTimeMake");
            LIFECMTimeRangeMakeAddr = (LIFECMTimeRangeMake_t *)dlsym(frameworkHandle, "CMTimeRangeMake");
        } else {
            LIFELogExtWarn(@"Buglife warning: Your app must link AVFoundation.framework to enable video attachments in bug reports.");
        }
    });
}
