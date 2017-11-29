//
//  LIFENetworkManager.h
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

typedef void (^LIFENetworkManagerSuccess)(id responseObject);
typedef void (^LIFENetworkManagerFailure)(NSError *error);

@interface LIFENetworkManager : NSObject

- (NSURLSessionTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters callbackQueue:(dispatch_queue_t)callbackQueue success:(LIFENetworkManagerSuccess)success failure:(LIFENetworkManagerFailure)failure;
- (NSURLSessionTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters callbackQueue:(dispatch_queue_t)callbackQueue success:(LIFENetworkManagerSuccess)success failure:(LIFENetworkManagerFailure)failure;

@end
