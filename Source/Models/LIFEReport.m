//
//  LIFEReport.m
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

#import "LIFEReport.h"
#import "LIFEReproStep.h"
#import "LIFEAppInfo.h"
#import "LIFEDeviceInfo.h"
#import "LIFEReportAttachmentImpl.h"
#import "LIFEMacros.h"
#import "NSArray+LIFEAdditions.h"
#import "NSMutableDictionary+LIFEAdditions.h"

@interface LIFEReport ()

@end

@implementation LIFEReport

#pragma mark - Public methods

- (NSString *)suggestedFilename
{
    return [NSString stringWithFormat:@"report_%.0f.snr", [_creationDate timeIntervalSince1970]];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        for (NSString *key in [[self class] _objectPropertyKeys]) {
            id value = [coder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        
        self.invocationMethod = [coder decodeIntegerForKey:NSStringFromSelector(@selector(invocationMethod))];
        self.submissionAttempts = [coder decodeIntegerForKey:NSStringFromSelector(@selector(submissionAttempts))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    for (NSString *key in [[self class] _objectPropertyKeys]) {
        id value = [self valueForKey:key];
        [coder encodeObject:value forKey:key];
    }
    
    [coder encodeInteger:self.invocationMethod forKey:NSStringFromSelector(@selector(invocationMethod))];
    [coder encodeInteger:self.submissionAttempts forKey:NSStringFromSelector(@selector(submissionAttempts))];
}

+ (NSArray<NSString *> *)_objectPropertyKeys
{
    return @[LIFE_STRING_FROM_SELECTOR_NAMED(whatHappened),
             LIFE_STRING_FROM_SELECTOR_NAMED(component),
             LIFE_STRING_FROM_SELECTOR_NAMED(reproSteps),
             LIFE_STRING_FROM_SELECTOR_NAMED(expectedResults),
             LIFE_STRING_FROM_SELECTOR_NAMED(actualResults),
             LIFE_STRING_FROM_SELECTOR_NAMED(screenshot),
             LIFE_STRING_FROM_SELECTOR_NAMED(creationDate),
             LIFE_STRING_FROM_SELECTOR_NAMED(logs),
             LIFE_STRING_FROM_SELECTOR_NAMED(appInfo),
             LIFE_STRING_FROM_SELECTOR_NAMED(deviceInfo),
             LIFE_STRING_FROM_SELECTOR_NAMED(userIdentifier),
             LIFE_STRING_FROM_SELECTOR_NAMED(userEmail),
             LIFE_STRING_FROM_SELECTOR_NAMED(attachments),
             LIFE_STRING_FROM_SELECTOR_NAMED(timeZoneName),
             LIFE_STRING_FROM_SELECTOR_NAMED(timeZoneAbbreviation),
             LIFE_STRING_FROM_SELECTOR_NAMED(attributes)];
}

#pragma mark - JSON serialization

- (NSDictionary *)JSONDictionary
{
    LIFEReport *report = self;
    NSMutableDictionary *reportDict = [[NSMutableDictionary alloc] init];
    
    [reportDict life_safeSetObject:report.whatHappened forKey:@"what_happened"];
    [reportDict life_safeSetObject:report.component forKey:@"component"];
    [reportDict life_safeSetObject:report._formattedReproSteps forKey:@"repro_steps"];
    [reportDict life_safeSetObject:report.expectedResults forKey:@"expected_results"];
    [reportDict life_safeSetObject:report.actualResults forKey:@"actual_results"];
    [reportDict life_safeSetObject:report._base64screenshotData forKey:@"base64_screenshot_data"];
    [reportDict life_safeSetObject:report._base64logData forKey:@"base64_log_data"];
    
    [reportDict life_safeSetObject:report.appInfo.bundleShortVersion forKey:@"bundle_short_version"];
    [reportDict life_safeSetObject:report.appInfo.bundleVersion forKey:@"bundle_version"];
    [reportDict life_safeSetObject:report.appInfo.bundleIdentifier forKey:@"bundle_identifier"];
    [reportDict life_safeSetObject:report.appInfo.bundleName forKey:@"bundle_name"];

    [reportDict life_safeSetObject:report.deviceInfo.operatingSystemVersion forKey:@"operating_system_version"];
    [reportDict life_safeSetObject:report.deviceInfo.deviceModel forKey:@"device_model"];
    [reportDict life_safeSetObject:report.deviceInfo.fileSystemSizeInBytes forKey:@"total_capacity_bytes"];
    [reportDict life_safeSetObject:report.deviceInfo.freeFileSystemSizeInBytes forKey:@"free_capacity_bytes"];
    [reportDict life_safeSetObject:report.deviceInfo.freeMemory forKey:@"free_memory_bytes"];
    [reportDict life_safeSetObject:report.deviceInfo.usableMemory forKey:@"total_memory_bytes"];
    [reportDict life_safeSetObject:report.deviceInfo.identifierForVendor forKey:@"device_identifier"];
    [reportDict life_safeSetObject:report.deviceInfo.localeIdentifier forKey:@"locale"];
    [reportDict life_safeSetObject:report.deviceInfo.carrierName forKey:@"carrier_name"];
    [reportDict life_safeSetObject:report.deviceInfo.currentRadioAccessTechnology forKey:@"current_radio_access_technology"];
    [reportDict life_safeSetObject:@(report.deviceInfo.wifiConnected) forKey:@"wifi_connected"];
    [reportDict life_safeSetObject:@(report.deviceInfo.batteryLevel) forKey:@"battery_level"];
    [reportDict life_safeSetObject:report._formattedAttachments forKey:@"attachments"];
    [reportDict life_safeSetObject:report.timeZoneName forKey:@"time_zone_name"];
    [reportDict life_safeSetObject:report.timeZoneAbbreviation forKey:@"time_zone_abbreviation"];
    
    if (report.deviceInfo.batteryState != LIFEDeviceBatteryStateUnknown) {
        [reportDict life_safeSetObject:@(report.deviceInfo.batteryState) forKey:@"battery_state"];
    }
    
    
    [reportDict life_safeSetObject:@(report.deviceInfo.lowPowerMode) forKey:@"low_power_mode"];
    
    [reportDict life_safeSetObject:report.userIdentifier forKey:@"user_identifier"];
    [reportDict life_safeSetObject:report.userEmail forKey:@"user_email"];
    [reportDict life_safeSetObject:@(report.invocationMethod) forKey:@"invocation_method"];
    [reportDict life_safeSetObject:@(report.submissionAttempts) forKey:@"submission_attempts"];
    [reportDict life_safeSetObject:report._formattedCreationDate forKey:@"invoked_at"];
    
    if (self.attributes.count > 0) {
        NSMutableDictionary *attributesJSON = [[NSMutableDictionary alloc] init];
        
        [self.attributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, LIFEAttribute * _Nonnull obj, BOOL * _Nonnull stop) {
            attributesJSON[key] = obj.JSONDictionary;
        }];
        
        [reportDict life_safeSetObject:attributesJSON forKey:@"attributes"];
    }
    
    return [NSDictionary dictionaryWithDictionary:reportDict];
}

- (NSString *)_formattedReproSteps
{
    NSMutableArray<NSString *> *reproStepStrings = [[NSMutableArray alloc] init];
    
    [self.reproSteps enumerateObjectsUsingBlock:^(LIFEReproStep *step, NSUInteger index, BOOL *stop) {
        NSString *stepString = [NSString stringWithFormat:@"%@. %@", @(index + 1), step.userDescription];
        [reproStepStrings addObject:stepString];
    }];
    
    if (reproStepStrings.count > 0) {
        return [reproStepStrings componentsJoinedByString:@"\n"];
    } else {
        return nil;
    }
}

- (NSString *)_formattedCreationDate
{
    NSDateFormatter *iso8601DateFormatter = [[NSDateFormatter alloc] init];
    [iso8601DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    [iso8601DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [iso8601DateFormatter stringFromDate:self.creationDate];
}

- (NSString *)_base64screenshotData
{
    if (self.screenshot) {
        NSData *imageData = UIImagePNGRepresentation(self.screenshot);
        NSString *imageDataString = [imageData base64EncodedStringWithOptions:0];
        return imageDataString;
    }
    
    return nil;
}

- (NSString *)_base64logData
{
    NSData *logData = [self.logs dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64encodedLogs = [logData base64EncodedStringWithOptions:0];
    return base64encodedLogs;
}

- (NSArray<NSDictionary *> *)_formattedAttachments
{
    return [self.attachments life_map:^id(LIFEReportAttachmentImpl *attachment) {
        return [attachment JSONDictionary];
    }];
}

@end
