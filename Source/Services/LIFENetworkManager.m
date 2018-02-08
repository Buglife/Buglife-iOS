//
//  LIFENetworkManager.m
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

#import "LIFENetworkManager.h"
#import "LIFEMacros.h"
#import "NSError+LIFEAdditions.h"

static NSString * const kBaseURL = @"https://www.buglife.com";
static BOOL LIFEStatusCodeIsSuccess(NSInteger statusCode);

@interface LIFENetworkManager ()

@property (nonatomic) NSURLSession *session;

@end

@implementation LIFENetworkManager

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPMaximumConnectionsPerHost = 1;
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

#pragma mark - Public methods

- (NSURLSessionTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters callbackQueue:(dispatch_queue_t)callbackQueue success:(LIFENetworkManagerSuccess)success failure:(LIFENetworkManagerFailure)failure
{
    return [self _taskWithHTTPMethod:@"PUT" URL:URLString parameters:parameters callbackQueue:callbackQueue success:success failure:failure];
}

- (NSURLSessionTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters callbackQueue:(dispatch_queue_t)callbackQueue success:(LIFENetworkManagerSuccess)success failure:(LIFENetworkManagerFailure)failure
{
    return [self _taskWithHTTPMethod:@"POST" URL:URLString parameters:parameters callbackQueue:callbackQueue success:success failure:failure];
}

#pragma mark - Private

- (NSURLSessionTask *)_taskWithHTTPMethod:(NSString *)HTTPMethod URL:(NSString *)URLString parameters:(NSDictionary *)parameters callbackQueue:(dispatch_queue_t)callbackQueue success:(LIFENetworkManagerSuccess)success failure:(LIFENetworkManagerFailure)failure
{
    NSURL *baseURL = [[self class] _baseURL];
    NSURL *url = [baseURL URLByAppendingPathComponent:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSParameterAssert(HTTPMethod);
    request.HTTPMethod = HTTPMethod;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    
    if (data == nil) {
        dispatch_async(callbackQueue, ^{
            failure(error);
        });
        
        return nil;
    }
    
    [request setHTTPBody:data];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger statusCode = httpResponse.statusCode;
            
            if (LIFEStatusCodeIsSuccess(statusCode) && data) {
                NSError *dataError;
                id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&dataError];
                NSParameterAssert(responseObject);
                
                dispatch_async(callbackQueue, ^{
                    success(responseObject);
                });
            } else {
                if (error == nil) {
                    error = [LIFENSError life_errorWithHTTPURLResponse:httpResponse];
                }
                
                dispatch_async(callbackQueue, ^{
                    failure(error);
                });
            }
        } else {
            dispatch_async(callbackQueue, ^{
                failure(error);
            });
        }
    }];
    
    [task resume];
    
    return task;
}

+ (NSURL *)_baseURL
{
    // The default API base URL can be overridden if, say, you're pointing to an internal Buglife instance
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *overrideURL = environment[@"com.buglife.base_url"];
    if (overrideURL) {
        NSLog(@"Running with overridden base url: %@", overrideURL);
        return [NSURL URLWithString:overrideURL];
    }
    
    return [NSURL URLWithString:kBaseURL];
}

@end

static BOOL LIFEStatusCodeIsSuccess(NSInteger statusCode) {
    return (statusCode == 200 || statusCode == 201);
}
