//
//  LIFEReachability.m
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

#import "LIFEReachability.h"
#import "LIFEMacros.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <dlfcn.h>

@interface LIFEReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef  reachabilityRef;
@property (nonatomic, strong) dispatch_queue_t          reachabilitySerialQueue;
@property (nonatomic, strong) id                        reachabilityObject;

-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags;

@end

#pragma mark - Dynamic framework loading

typedef typeof(SCNetworkReachabilityCreateWithAddress) SCNetworkReachabilityCreateWithAddress_t;
static SCNetworkReachabilityCreateWithAddress_t *SCNetworkReachabilityCreateWithAddressAddr = 0;

typedef typeof(SCNetworkReachabilityGetFlags) SCNetworkReachabilityGetFlags_t;
static SCNetworkReachabilityGetFlags_t *SCNetworkReachabilityGetFlagsAddr = 0;

void LIFELoadSystemConfiguration() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *frameworkHandle = dlopen("/System/Library/Frameworks/SystemConfiguration.framework/SystemConfiguration", RTLD_LAZY | RTLD_GLOBAL);
        
        if (frameworkHandle) {
            
            SCNetworkReachabilityCreateWithAddressAddr = (SCNetworkReachabilityCreateWithAddress_t *)dlsym(frameworkHandle, "SCNetworkReachabilityCreateWithAddress");
            
            SCNetworkReachabilityGetFlagsAddr = (SCNetworkReachabilityGetFlags_t *)dlsym(frameworkHandle, "SCNetworkReachabilityGetFlags");
            
            
        } else {
            LIFELogExtWarn(@"Buglife warning: Your app must link SystemConfiguration.framework to get network reachability with bug reports.");
        }
    });
}

SCNetworkReachabilityRef LIFESCNetworkReachabilityCreateWithAddress(CFAllocatorRef __nullable allocator, const struct sockaddr *address)
{
    LIFELoadSystemConfiguration();
    
    if (SCNetworkReachabilityCreateWithAddressAddr) {
        return (*SCNetworkReachabilityCreateWithAddressAddr)(allocator, address);
    } else {
        return NULL;
    }
}

Boolean LIFESCNetworkReachabilityGetFlags(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags *flags)
{
    LIFELoadSystemConfiguration();
    
    if (SCNetworkReachabilityGetFlagsAddr) {
        return (*SCNetworkReachabilityGetFlagsAddr)(target, flags);
    } else {
        return false;
    }
}

@implementation LIFEReachability

#pragma mark - Class Constructor Methods

+(instancetype)reachabilityWithAddress:(void *)hostAddress
{
    SCNetworkReachabilityRef ref = LIFESCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    if (ref)
    {
        id reachability = [[self alloc] initWithReachabilityRef:ref];
        
        return reachability;
    }
    
    return nil;
}

+(instancetype)reachabilityForLocalWiFi
{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len            = sizeof(localWifiAddress);
    localWifiAddress.sin_family         = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr    = htonl(IN_LINKLOCALNETNUM);
    
    return [self reachabilityWithAddress:&localWifiAddress];
}


// Initialization methods

-(instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)ref
{
    self = [super init];
    if (self != nil)
    {
        self.reachableOnWWAN = YES;
        self.reachabilityRef = ref;
        
        // We need to create a serial queue.
        // We allocate this once for the lifetime of the notifier.
        
        self.reachabilitySerialQueue = dispatch_queue_create("com.tonymillion.reachability", NULL);
    }
    
    return self;
}

-(void)dealloc
{
    if(self.reachabilityRef)
    {
        CFRelease(self.reachabilityRef);
        self.reachabilityRef = nil;
    }

    self.reachabilitySerialQueue = nil;
}

#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags
{
    BOOL connectionUP = YES;
    
    if(!(flags & kSCNetworkReachabilityFlagsReachable))
        connectionUP = NO;
    
    if( (flags & testcase) == testcase )
        connectionUP = NO;
    
#if	TARGET_OS_IPHONE
    if(flags & kSCNetworkReachabilityFlagsIsWWAN)
    {
        // We're on 3G.
        if(!self.reachableOnWWAN)
        {
            // We don't want to connect when on 3G.
            connectionUP = NO;
        }
    }
#endif
    
    return connectionUP;
}

-(BOOL)isReachableViaWiFi
{
    SCNetworkReachabilityFlags flags = 0;
    
    if(LIFESCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        // Check we're reachable
        if((flags & kSCNetworkReachabilityFlagsReachable))
        {
#if	TARGET_OS_IPHONE
            // Check we're NOT on WWAN
            if((flags & kSCNetworkReachabilityFlagsIsWWAN))
            {
                return NO;
            }
#endif
            return YES;
        }
    }
    
    return NO;
}

@end
