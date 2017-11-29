//
//  LIFESwizzler.m
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

#import "LIFESwizzler.h"
#import "LIFEMacros.h"
#import <objc/runtime.h>

#if TARGET_OS_IPHONE
#else
#error This hasn't been tested outside of iOS!
#endif

#define SetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)	\
if (ERROR_VAR) {	\
NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
*ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
code:-1	\
userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
}
#define SetNSError(ERROR_VAR, FORMAT,...) SetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

#define GetClass(obj)	object_getClass(obj)

@implementation LIFESwizzler

#pragma mark - Actual swizzling

+ (BOOL)instanceSwizzleFromClass:(Class)origClass andMethod:(SEL)origSel toClass:(Class)altClass andMethod:(SEL)altSel
{
    Method origMethod = class_getInstanceMethod(origClass, origSel);
    if (!origMethod) {
        LIFELogIntError(@"Original method %@ not found for class %@", NSStringFromSelector(origSel), NSStringFromClass(origClass));
        NSParameterAssert(NO);
        return NO;
    }
    
    Method altMethod = class_getInstanceMethod(altClass, altSel);
    if (!altMethod) {
        LIFELogIntError(@"Alternate method %@ not found for class %@", NSStringFromSelector(origSel), NSStringFromClass(origClass));
        NSParameterAssert(NO);
        return NO;
    }
    
    class_addMethod(origClass, origSel, class_getMethodImplementation(origClass, origSel), method_getTypeEncoding(origMethod));
    class_addMethod(altClass, altSel, class_getMethodImplementation(altClass, altSel), method_getTypeEncoding(altMethod));
    method_exchangeImplementations(class_getInstanceMethod(origClass, origSel), class_getInstanceMethod(altClass, altSel));
    return YES;
}

+ (BOOL)classSwizzleFromClass:(Class)origClass andMethod:(SEL)origSel toClass:(Class)altClass andMethod:(SEL)altSel
{
    return [self instanceSwizzleFromClass:GetClass(origClass) andMethod:origSel toClass:GetClass(altClass) andMethod:altSel];
}

IMP LIFEReplaceMethodWithBlock(Class c, SEL origSEL, id block) {
    NSCParameterAssert(block);
    
    // get original method
    Method origMethod = class_getInstanceMethod(c, origSEL);
    NSCParameterAssert(origMethod);
    
    // convert block to IMP trampoline and replace method implementation
    IMP newIMP = imp_implementationWithBlock(block);
    
    // Try adding the method if not yet in the current class
    if (!class_addMethod(c, origSEL, newIMP, method_getTypeEncoding(origMethod))) {
        return method_setImplementation(origMethod, newIMP);
    }else {
        return method_getImplementation(origMethod);
    }
}

@end
