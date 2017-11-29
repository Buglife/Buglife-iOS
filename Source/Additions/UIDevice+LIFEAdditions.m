//
//  UIDevice+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 12/13/16.
//
//

#import "UIDevice+LIFEAdditions.h"
#include <sys/sysctl.h>

@implementation UIDevice (LIFEAdditions)

LIFE_CATEGORY_METHOD_IMPL(UIDevice)

- (BOOL)life_isSimulator
{
    NSString *modeIdentifier = [self _life_getSysInfoByName:"hw.machine"];
    return [modeIdentifier isEqualToString:@"x86_64"];
}

- (NSString *)_life_getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

@end

LIFE_CATEGORY_FUNCTION_IMPL(UIDevice);
