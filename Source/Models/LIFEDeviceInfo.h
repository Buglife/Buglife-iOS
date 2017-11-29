//
//  LIFEDeviceInfo.h
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
#import "LIFEDeviceBatteryState.h"

@interface LIFEDeviceInfo : NSObject <NSCoding>

@property (nonatomic) NSString *operatingSystemVersion;
@property (nonatomic) NSString *deviceModel;
@property (nonatomic) NSNumber *fileSystemSizeInBytes;
@property (nonatomic) NSNumber *freeFileSystemSizeInBytes;
@property (nonatomic) NSNumber *freeMemory;
@property (nonatomic) NSNumber *usableMemory;
@property (nonatomic) NSString *identifierForVendor;
@property (nonatomic) NSString *localeIdentifier;
@property (nonatomic) NSString *carrierName;
@property (nonatomic) NSString *currentRadioAccessTechnology;
@property (nonatomic) BOOL wifiConnected;
@property (nonatomic) float batteryLevel;
@property (nonatomic) LIFEDeviceBatteryState batteryState;
@property (nonatomic) BOOL lowPowerMode;

@end
