//
//  NSError+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 12/9/15.
//
//

#import "NSError+LIFEAdditions.h"

@implementation LIFENSError

+ (NSString *)life_debugDescriptionForError:(NSError *)error
{
    return error.debugDescription;
}

#pragma mark - Factory methods

static NSString * const kErrorDomain = @"com.buglife.NetworkManager.ErrorDomain";
static const NSInteger kErrorCodeUnexpectedStatusCode = 71; // starting at 71 cause why not

+ (NSError *)life_errorWithHTTPURLResponse:(NSHTTPURLResponse *)httpResponse
{
    NSInteger statusCode = httpResponse.statusCode;
    NSString *requestID = httpResponse.allHeaderFields[@"X-Request-Id"];
    NSString *description = [NSString stringWithFormat:@"Buglife API returned status code %ld.", (long)statusCode];
    NSMutableDictionary *userInfo = @{@"statusCode" : @(statusCode)}.mutableCopy;
    
    if (requestID) {
        [userInfo setObject:requestID forKey:@"requestID"];
        description = [description stringByAppendingFormat:@" Request ID: %@", requestID];
    }
    
    userInfo[NSLocalizedDescriptionKey] = description;
    return [NSError errorWithDomain:kErrorDomain code:kErrorCodeUnexpectedStatusCode userInfo:userInfo];
}

@end
