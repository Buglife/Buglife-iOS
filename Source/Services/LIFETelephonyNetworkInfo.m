//
//  LIFETelephonyNetworkInfo.m
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

#import "LIFETelephonyNetworkInfo.h"
#import "LIFEMacros.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#pragma mark - Protocols

@protocol LIFECTCarrier <NSObject>

- (nullable NSString *)carrierName;

@end

@protocol LIFECTTelephonyNetworkInfo <NSObject>

- (id<LIFECTCarrier>)subscriberCellularProvider;
- (nullable NSString *)currentRadioAccessTechnology;

@end

#pragma mark - LIFETelephonyNetworkInfo

@interface LIFETelephonyNetworkInfo ()

@property (nonatomic, nullable) NSObject<LIFECTTelephonyNetworkInfo> *networkInfo;
@property (nonatomic, nullable) NSObject<LIFECTCarrier> *carrier;

@end

@implementation LIFETelephonyNetworkInfo

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _life_privateInit];
    }
    return self;
}

- (void)_life_privateInit
{
    NSParameterAssert(![NSThread isMainThread]);
    Class NetworkInfoClass = NSClassFromString(@"CTTelephonyNetworkInfo");
    
    if (NetworkInfoClass) {
        NSObject<LIFECTTelephonyNetworkInfo> *networkInfo = [[NetworkInfoClass alloc] init];
        
        if (networkInfo) {
            if ([networkInfo respondsToSelector:@selector(currentRadioAccessTechnology)]) {
                _currentRadioAccessTechnology = networkInfo.currentRadioAccessTechnology;
            } else {
                LIFELogExtError(@"Buglife error: Internal error getting carrer info (203). Please report this!");
            }

            if ([networkInfo respondsToSelector:@selector(subscriberCellularProvider)]) {
                NSObject<LIFECTCarrier> *carrier = networkInfo.subscriberCellularProvider;
                
                if (carrier) {
                    if ([carrier respondsToSelector:@selector(carrierName)]) {
                        _carrierName = carrier.carrierName;
                    } else {
                        LIFELogExtError(@"Buglife error: Internal error getting carrer info (201). Please report this!");
                    }
                }
            } else {
                LIFELogExtError(@"Buglife error: Internal error getting carrer info (202). Please report this!");
            }
        }
    } else {
        LIFELogExtWarn(@"Buglife warning: Your app must link CoreTelephony.framework to get carrier information with bug reports.");
    }
}

@end
