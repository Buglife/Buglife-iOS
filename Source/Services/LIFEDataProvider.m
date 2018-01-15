//
//  LIFEDataProvider.m
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

#import "LIFEDataProvider.h"
#import "LIFEReport.h"
#import "LIFEReproStep.h"
#import "LIFEMacros.h"
#import "LIFEAppInfo.h"
#import "LIFEAppInfoProvider.h"
#import "LIFENetworkManager.h"
#import "LIFEUserDefaults.h"
#import "LIFEReportOwner.h"
#import "Buglife+Protected.h"
#import "NSMutableDictionary+LIFEAdditions.h"
#import "NSError+LIFEAdditions.h"

// This can be used to test the migration path
#define USES_LEGACY_PENDING_REPORTS_DIRECTORY 0

#if USES_LEGACY_PENDING_REPORTS_DIRECTORY
#warning Legacy pending reports directory is enabled!
#warning DO NOT SHIP THIS
#endif

static NSString * const kBuglifeDirectory = @"com.buglife.buglife";
static NSString * const kLegacyPendingReportsDirectory = @"cached_reports";
static NSString * const kPendingReportsDirectory = @"pending_reports";
static NSString * const kPlatform = @"ios";

@interface LIFEDataProvider ()

@property (nonatomic) LIFEReportOwner *reportOwner;
@property (nonatomic) NSString *sdkVersion;
@property (nonatomic) NSString *sdkName;
@property (nonatomic) LIFEAppInfoProvider *appInfoProvider;
@property (nonatomic) LIFENetworkManager *networkManager;
@property (nonatomic) dispatch_queue_t workQueue;

@end

@implementation LIFEDataProvider

#pragma mark - Initialization

- (instancetype)initWithReportOwner:(LIFEReportOwner *)reportOwner SDKVersion:(NSString *)sdkVersion
{
    self = [super init];
    if (self) {
        _reportOwner = reportOwner;
        _sdkVersion = sdkVersion;
        _sdkName = NSClassFromString(@"RNBuglife") != Nil ? @"Buglife React Native iOS" : @"Buglife iOS";
        _appInfoProvider = [[LIFEAppInfoProvider alloc] init];
        _networkManager = [[LIFENetworkManager alloc] init];
        _workQueue = dispatch_queue_create("com.buglife.LIFEDataProvider.workQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)init
{
    LIFE_THROW_UNAVAILABLE_EXCEPTION(initWithReportOwner:SDKVersion:);
}

#pragma mark - Client Events

- (void)logClientEventWithName:(nonnull NSString *)eventName afterDelay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self logClientEventWithName:eventName];
    });
}

- (void)logClientEventWithName:(nonnull NSString *)eventName
{
    LIFELogIntDebug(@"Logging event: \"%@\"", eventName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [self.reportOwner switchCaseAPIKey:^(NSString *apiKey) {
        [LIFENSMutableDictionaryify(params) life_safeSetObject:apiKey forKey:@"api_key"];
    } email:^(NSString * _Nonnull email) {
        [LIFENSMutableDictionaryify(params) life_safeSetObject:email forKey:@"email"];
    }];

    NSString *deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSString *userIdentifier = [Buglife sharedBuglife].userIdentifier;
    NSString *userEmail = [Buglife sharedBuglife].userEmail;
    NSMutableDictionary *clientEventParams = [NSMutableDictionary dictionary];
    [clientEventParams life_safeSetObject:_sdkVersion forKey:@"sdk_version"];
    [clientEventParams life_safeSetObject:_sdkName forKey:@"sdk_name"];
    [clientEventParams life_safeSetObject:eventName forKey:@"event_name"];
    [clientEventParams life_safeSetObject:userIdentifier forKey:@"user_identifier"];
    [clientEventParams life_safeSetObject:userEmail forKey:@"user_email"];
    [clientEventParams life_safeSetObject:deviceIdentifier forKey:@"device_identifier"];

    [_appInfoProvider asyncFetchAppInfoToQueue:_workQueue completion:^(LIFEAppInfo *appInfo) {
        clientEventParams[@"bundle_short_version"] = appInfo.bundleShortVersion;
        clientEventParams[@"bundle_version"] = appInfo.bundleVersion;
        
        NSMutableDictionary *appParams = [NSMutableDictionary dictionary];
        [appParams life_safeSetObject:appInfo.bundleIdentifier forKey:@"bundle_identifier"];
        [appParams life_safeSetObject:kPlatform forKey:@"platform"];
        [appParams life_safeSetObject:appInfo.bundleName forKey:@"bundle_name"];

        [params life_safeSetObject:appParams forKey:@"app"];
        [params life_safeSetObject:clientEventParams forKey:@"client_event"];
        
        [self.networkManager POST:@"api/v1/client_events.json" parameters:params callbackQueue:self.workQueue success:^(id responseObject) {
            LIFELogIntDebug(@"Successfully posted event \"%@\"", eventName);
        } failure:^(NSError *error) {
            LIFELogIntError(@"Error posting event \"%@\"\n  Error: %@", eventName, error);
        }];
    }];
}

#pragma mark - Public methods

- (void)submitReport:(nonnull LIFEReport *)report withRetryPolicy:(LIFERetryPolicy)retryPolicy completion:(nullable LIFEDataProviderSubmitCompletion)completion;
{
    dispatch_async(_workQueue, ^{
        // Ain't no retain cycles here since our whole framework lives in a singleton :P
        [self _submitReport:report withRetryPolicy:retryPolicy fromPendingReportsDirectory:NO completion:completion];
    });
}

- (void)flushPendingReportsAfterDelay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), _workQueue, ^{
        // Ain't no retain cycles here since our whole framework lives in a singleton :P
        [self _flushPendingReports];
    });
}

#pragma mark - Private methods

- (void)_submitReport:(nonnull LIFEReport *)report withRetryPolicy:(LIFERetryPolicy)retryPolicy fromPendingReportsDirectory:(BOOL)isFromPendingReportsDir completion:(nullable LIFEDataProviderSubmitCompletion)completion
{
    NSParameterAssert(self.reportOwner);
    NSParameterAssert(self.sdkVersion);
    
    // Submission attempts should be incremented *before* serializing to JSON or caching.
    report.submissionAttempts += 1;

    NSMutableDictionary *reportDict = [report JSONDictionary].mutableCopy;
    [LIFENSMutableDictionaryify(reportDict) life_safeSetObject:self.sdkVersion forKey:@"sdk_version"];
    [LIFENSMutableDictionaryify(reportDict) life_safeSetObject:self.sdkName forKey:@"sdk_name"];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"report"] = reportDict;
    
    [self.reportOwner switchCaseAPIKey:^(NSString *apiKey) {
        [LIFENSMutableDictionaryify(mutableParameters) life_safeSetObject:apiKey forKey:@"api_key"];
    } email:^(NSString * _Nonnull email) {
        [LIFENSMutableDictionaryify(mutableParameters) life_safeSetObject:email forKey:@"email"];
    }];
    
    NSMutableDictionary *appDict = [report.appInfo JSONDictionary].mutableCopy;
    mutableParameters[@"app"] = appDict;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    BOOL saveFailedSubmissions = (!isFromPendingReportsDir && retryPolicy == LIFERetryPolicyNextLaunch);
    BOOL removeSuccessfulSubmissions = (saveFailedSubmissions || isFromPendingReportsDir);
    
    // Save pending reports if required by the retry policy
    if (saveFailedSubmissions) {
        // TODO: Need to remove & re-save so that submissionAttempts actually increments beyond 2
        [self _savePendingReport:report];
    }
    
    [_networkManager POST:@"api/v1/reports.json" parameters:parameters callbackQueue:self.workQueue success:^(id responseObject) {

        LIFELogIntInfo(@"Report submitted!");
        if (removeSuccessfulSubmissions) {
            [self _removeSavedReport:report];
        }
        
        if (completion) {
            completion(YES);
        }
    } failure:^(NSError *error) {
        LIFELogIntInfo(@"Error submitting report; Error: %@", [LIFENSError life_debugDescriptionForError:error]);
        
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)_flushPendingReports
{
    [self _migratePendingReportsFromLegacyDirectory];
    
    NSArray<LIFEReport *> *pendingReports = [self _pendingReports];
    LIFELogIntInfo(@"Found %lu pending reports", (unsigned long)pendingReports.count);
    
    for (LIFEReport *report in pendingReports) {
        [self _submitReport:report withRetryPolicy:LIFERetryPolicyNextLaunch fromPendingReportsDirectory:YES completion:nil];
    }
}

- (void)_savePendingReport:(LIFEReport *)report
{
    NSString *filename = [report suggestedFilename];
    NSURL *url = [[self _pendingReportsDirectory] URLByAppendingPathComponent:filename isDirectory:NO];
    NSData *reportData = [NSKeyedArchiver archivedDataWithRootObject:report];
    BOOL saved = [reportData writeToURL:url atomically:YES];
    NSParameterAssert(saved);
    
    if (!saved) {
        LIFELogExtError(@"Buglife Error: Unable to pending bug report to local filesystem! Please let us know about this by emailing support@buglife.com.");
    }
}

- (void)_removeSavedReport:(LIFEReport *)report
{
    NSString *filename = [report suggestedFilename];
    NSURL *url = [[self _pendingReportsDirectory] URLByAppendingPathComponent:filename isDirectory:NO];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL deleted = [fileManager removeItemAtURL:url error:&error];
    
    if (!deleted) {
        // TODO: Log visibly to users! This is a serious error
        LIFELogExtError(@"Buglife Error: Report was uploaded on subsequent attempt, but we were unable to remove the pending report from disk! Error details: %@", error);
        NSParameterAssert(NO);
    }
}

- (NSArray<LIFEReport *> *)_pendingReports
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray<NSURL *> *files = [fileManager contentsOfDirectoryAtURL:[self _pendingReportsDirectory] includingPropertiesForKeys:nil options:0 error:&error];
    
    if (files == nil) {
        LIFELogExtError(@"Buglife Error: We were unable to read from the pending reports directory. This may cause problems when retrying report submission. Error details: %@", error);
        NSParameterAssert(NO);
        return nil;
    }
    
    NSMutableArray *pendingReports = [[NSMutableArray alloc] init];
    
    for (NSURL *fileURL in files) {
        error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL options:0 error:&error];
        
        if (data == nil) {
            LIFELogExtError(@"Buglife Error: Couldn't read file at URL (%@). Error details: %@", fileURL, error);
            NSParameterAssert(NO);
            continue;
        } else {
            NSData *data = [NSData dataWithContentsOfURL:fileURL];
            NSAssert(data, @"Couldn't initialize data from URL: %@", fileURL);
            LIFEReport *report = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            if (report) {
                [pendingReports addObject:report];
            } else {
                LIFELogExtError(@"Buglife Error: Something went wrong when reading a pending report from disk.");
                NSAssert(NO, @"Failed to unarchive report at path: %@", fileURL);
            }
        }
    }
    
    return [[NSArray alloc] initWithArray:pendingReports];
}

- (NSURL *)_pendingReportsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSURL *> *urls = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *url = urls.firstObject;
    url = [url URLByAppendingPathComponent:kBuglifeDirectory isDirectory:YES];
    url = [url URLByAppendingPathComponent:kPendingReportsDirectory isDirectory:YES];
    
#if USES_LEGACY_PENDING_REPORTS_DIRECTORY
    url = [self _legacyPendingReportsDirectory];
    LIFELogDebug(@"Using legacy pending reports directory");
#endif
    
    NSError *error;
    BOOL directoryCreated = [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (!directoryCreated) {
        LIFELogExtError(@"Buglife Error: Unable create directory for pending bug reports. Error details: %@", error);
        NSParameterAssert(NO);
        return nil;
    }
    
    return url;
}

#pragma mark - Legacy pending report storage

- (NSURL *)_legacyPendingReportsDirectory
{
    return [[self _legacyBuglifeDirectory] URLByAppendingPathComponent:kLegacyPendingReportsDirectory isDirectory:YES];;
}

- (NSURL *)_legacyBuglifeDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSURL *> *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *url = urls.firstObject;
    return [url URLByAppendingPathComponent:kBuglifeDirectory isDirectory:YES];
}

/**
 Up until Buglife ~1.6.1, we stored reports in the app's NSDocumentDirectory, under `com.buglife.buglife/cached_reports`.
 Two problems with this:
 
 1. They're not really "cached" reports, since they can't be recreated; they're reports pending submission (i.e. first submission failed)
 2. The NSDocumentDirectory is apparently exposed to the user (according to Apple's docs).
 
 Moving forward, we now store pending reports in the app's NSApplicationSupportDirectory, under `com.buglife.buglife/pending_reports`.
 
 This method migrates reports from the old legacy directory to the new directory, and deletes the old legacy directory.
 */
- (BOOL)_migratePendingReportsFromLegacyDirectory
{
#if USES_LEGACY_PENDING_REPORTS_DIRECTORY
    LIFELogDebug(@"Using legacy pending reports directory; skipping migration");
    return false;
#endif
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *legacyPendingReportsDirectory = [self _legacyPendingReportsDirectory];
    NSURL *pendingReportsDirectory = [self _pendingReportsDirectory];
    
    // If the legacy pending reports directory exists, then migrate all reports to the new pending reports directory, and delete the old directory
    if ([fileManager fileExistsAtPath:legacyPendingReportsDirectory.path]) {
        NSError *error;
        NSArray<NSURL *> *files = [fileManager contentsOfDirectoryAtURL:legacyPendingReportsDirectory includingPropertiesForKeys:nil options:0 error:&error];
        
        if (files == nil) {
            LIFELogExtError(@"Buglife Error: Pending reports migration failed, unable to get contents of legacy pending reports directory: %@", error);
            NSParameterAssert(NO);
            return false;
        }
        
        for (NSURL *oldFileURL in files) {
            error = nil;
            NSString *filename = oldFileURL.lastPathComponent;
            NSURL *newFileURL = [pendingReportsDirectory URLByAppendingPathComponent:filename];
            BOOL moved = [fileManager moveItemAtURL:oldFileURL toURL:newFileURL error:&error];
            
            if (!moved) {
                LIFELogExtError(@"Buglife Error: Pending reports migration failed, unable to move file: %@", error);
                NSParameterAssert(NO);
                return false;
            }
        }
        
        // After we've moved each file, delete the old directory
        error = nil;
        BOOL deleted = [fileManager removeItemAtURL:legacyPendingReportsDirectory error:&error];
        
        if (!deleted) {
            LIFELogExtError(@"Buglife Error: Pending reports migration failed, unable to delete legacy pending reports directory: %@", error);
            NSParameterAssert(NO);
            return false;
        }
        
        error = nil;
        deleted = [fileManager removeItemAtURL:[self _legacyBuglifeDirectory] error:&error];
        
        if (!deleted) {
            LIFELogExtError(@"Buglife Error: Pending reports migration failed, unable to delete legacy Buglife directory: %@", error);
            NSParameterAssert(NO);
            return false;
        }
        
        LIFELogIntDebug(@"Report migrator successfully moved %@ reports.", @(files.count));
        return true; // Everything migrated successfully!
    }
    
    return false; // Nothing was migrated
}

@end
