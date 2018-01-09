//
//  LIFEDeviceInfoProvider.m
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

#import "LIFEDeviceInfoProvider.h"
#import "LIFEMacros.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import "LIFETelephonyNetworkInfo.h"
#import "LIFEReachability.h"
#import "LIFEDeviceInfo.h"
#import "LIFEAttribute.h"

NSNumber *life_mach_freeMemory(void);
NSNumber *life_mach_usableMemory(void);
static LIFEDeviceBatteryState LIFEDeviceBatteryStateFromUIDeviceBatteryState(UIDeviceBatteryState batteryState);
static NSString *LIFEThermalStateStringFromThermalState(NSProcessInfoThermalState thermalState) API_AVAILABLE(ios(11.0));;
static NSString *LIFEContentSizeCategoryFromUIContentSizeCategory(UIContentSizeCategory contentSizeCategory);

@implementation LIFEDeviceInfoProvider

#pragma mark - Public methods

- (void)fetchDeviceInfoToQueue:(dispatch_queue_t)completionQueue completion:(void (^)(LIFEDeviceInfo *, LIFEAttributes *))completionHandler
{
    LIFEDeviceInfo *deviceInfo = [[LIFEDeviceInfo alloc] init];
    
    NSDictionary *fileSystemAttributes = [self _fileSystemAttributes];
    deviceInfo.fileSystemSizeInBytes = fileSystemAttributes[NSFileSystemSize];
    deviceInfo.freeFileSystemSizeInBytes = fileSystemAttributes[NSFileSystemFreeSize];
    
    deviceInfo.freeMemory = life_mach_freeMemory();
    deviceInfo.usableMemory = life_mach_usableMemory();
    
    LIFETelephonyNetworkInfo *networkInfo = [[LIFETelephonyNetworkInfo alloc] init];
    deviceInfo.carrierName = networkInfo.carrierName;
    deviceInfo.currentRadioAccessTechnology = networkInfo.currentRadioAccessTechnology;
    
    LIFEReachability *reachability = [LIFEReachability reachabilityForLocalWiFi];
    deviceInfo.wifiConnected = [reachability isReachableViaWiFi];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        LIFEMutableAttributes *attributes = [[LIFEMutableAttributes alloc] init];
        BOOL reduceMotionEnabled = UIAccessibilityIsReduceMotionEnabled();
        attributes[@"Reduce motion enabled"] = [LIFEAttribute attributeWithBool:reduceMotionEnabled flags:LIFEAttributeFlagSystem];
        
        UIContentSizeCategory uiContentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];
        NSString *contentSizeCategory = LIFEContentSizeCategoryFromUIContentSizeCategory(uiContentSizeCategory);
        
        if (contentSizeCategory) {
            attributes[@"Content size category"] = [LIFEAttribute attributeWithString:contentSizeCategory flags:LIFEAttributeFlagSystem];
        }
        
        // Probably shouldn't be accessing UIKit off the main thread.
        // (I'd almost consider UIDevice an exception, but let's play it safe)
        UIDevice *currentDevice = [UIDevice currentDevice];
        deviceInfo.operatingSystemVersion = [currentDevice systemVersion];
        deviceInfo.identifierForVendor = [currentDevice identifierForVendor].UUIDString;
        deviceInfo.deviceModel = [LIFEDeviceInfoProvider _deviceModel];
        
        // I also can't seem to find anything that confirms the thread safety of NSLocale :-/
        deviceInfo.localeIdentifier = [NSLocale currentLocale].localeIdentifier;
        
        BOOL wasBatteryMonitoringEnabled = currentDevice.batteryMonitoringEnabled;
        currentDevice.batteryMonitoringEnabled = YES;
        
        if (currentDevice.batteryMonitoringEnabled) {
            deviceInfo.batteryLevel = currentDevice.batteryLevel;
            deviceInfo.batteryState = LIFEDeviceBatteryStateFromUIDeviceBatteryState(currentDevice.batteryState);
            
            NSProcessInfo *processInfo = [NSProcessInfo processInfo];
            
            if ([processInfo respondsToSelector:@selector(isLowPowerModeEnabled)]) {
                deviceInfo.lowPowerMode = [[NSProcessInfo processInfo] isLowPowerModeEnabled];
            }
            
            if (@available(iOS 11.0, *)) {
                NSString *thermalState = LIFEThermalStateStringFromThermalState(processInfo.thermalState);
                
                if (thermalState) {
                    attributes[@"Thermal state"] = [LIFEAttribute attributeWithString:thermalState flags:LIFEAttributeFlagSystem];
                }
            }
        }
        
        currentDevice.batteryMonitoringEnabled = wasBatteryMonitoringEnabled;
        
        dispatch_async(completionQueue, ^{
            completionHandler(deviceInfo, attributes.copy);
        });
    });
}

#pragma mark - Private methods

+ (NSString *)_deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

// Keys of interest: NSFileSystemFreeSize and NSFileSystemSize
- (NSDictionary *)_fileSystemAttributes
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentPaths.lastObject;
    
    if (documentPath) {
        NSError *error;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:documentPath error:&error];
        
        if (attributes) {
            return attributes;
        } else {
            NSParameterAssert(NO);
            LIFELogIntDebug(@"Error getting file system attributes: %@", error);
        }
    } else {
        NSParameterAssert(NO);
        LIFELogIntDebug(@"Error accessing documentsPath");
    }
    
    return nil;
}

#pragma mark - Mach stuff

bool life_mach_i_VMStats(vm_statistics_data_t* const vmStats,
                      vm_size_t* const pageSize)
{
    kern_return_t kr;
    const mach_port_t hostPort = mach_host_self();
    
    if((kr = host_page_size(hostPort, pageSize)) != KERN_SUCCESS)
    {
        // TODO: Log this?
        //KSLOG_ERROR("host_page_size: %s", mach_error_string(kr));
        return false;
    }
    
    mach_msg_type_number_t hostSize = sizeof(*vmStats) / sizeof(natural_t);
    kr = host_statistics(hostPort,
                         HOST_VM_INFO,
                         (host_info_t)vmStats,
                         &hostSize);
    if(kr != KERN_SUCCESS)
    {
        // TODO: Log this?
        //KSLOG_ERROR("host_statistics: %s", mach_error_string(kr));
        return false;
    }
    
    return true;
}

NSNumber *life_mach_freeMemory()
{
    vm_statistics_data_t vmStats;
    vm_size_t pageSize;
    if(life_mach_i_VMStats(&vmStats, &pageSize))
    {
        uint64_t result = ((uint64_t)pageSize) * vmStats.free_count;
        return [NSNumber numberWithUnsignedLongLong:result];
    }
    return nil;
}

NSNumber *life_mach_usableMemory()
{
    vm_statistics_data_t vmStats;
    vm_size_t pageSize;
    if(life_mach_i_VMStats(&vmStats, &pageSize))
    {
        uint64_t result = ((uint64_t)pageSize) * (vmStats.active_count +
                                       vmStats.inactive_count +
                                       vmStats.wire_count +
                                       vmStats.free_count);
        return [NSNumber numberWithUnsignedLongLong:result];
    }
    return nil;
}

@end

static LIFEDeviceBatteryState LIFEDeviceBatteryStateFromUIDeviceBatteryState(UIDeviceBatteryState batteryState) {
    switch (batteryState) {
        case UIDeviceBatteryStateUnknown:
            return LIFEDeviceBatteryStateUnknown;
        case UIDeviceBatteryStateUnplugged:
            return LIFEDeviceBatteryStateUnplugged;
        case UIDeviceBatteryStateCharging:
            return LIFEDeviceBatteryStateCharging;
        case UIDeviceBatteryStateFull:
            return LIFEDeviceBatteryStateFull;
        default:
            break;
    }
}

static NSString *LIFEThermalStateStringFromThermalState(NSProcessInfoThermalState thermalState) {
    switch (thermalState) {
        case NSProcessInfoThermalStateCritical:
            return @"critical";
        case NSProcessInfoThermalStateFair:
            return @"fair";
        case NSProcessInfoThermalStateNominal:
            return @"nominal";
        case NSProcessInfoThermalStateSerious:
            return @"serious";
        default:
            return nil;
    }
}

static NSString *LIFEContentSizeCategoryFromUIContentSizeCategory(UIContentSizeCategory contentSizeCategory) {
    if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraSmall]) {
        return @"extra small";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategorySmall]) {
        return @"small";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryMedium]) {
        return @"medium";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryLarge]) {
        return @"large";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraLarge]) {
        return @"extra large";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
        return @"extra extra large";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
        return @"extra extra extra large";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityMedium]) {
        return @"accessibility medium";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityLarge]) {
        return @"accessibility large";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityExtraLarge]) {
        return @"accessibility extra large";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraLarge]) {
        return @"accessibility extra extra large";
    } else if ([contentSizeCategory isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge]) {
        return @"accessibility extra extra extra large";
    }
    
    return nil;
}
