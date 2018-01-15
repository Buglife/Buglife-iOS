//
//  LIFEMacros.h
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

#ifndef LIFEMacros_h
#define LIFEMacros_h

#define LIFE_THROW_UNAVAILABLE_EXCEPTION(useselector) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"[%@ %@] is unavailable; please use [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSStringFromClass([self class]), NSStringFromSelector(@selector(useselector))] userInfo:nil]

#define LIFEAssertMainThread NSParameterAssert([NSThread isMainThread])
#define LIFEAssertIsKindOfClass(obj, clazz) NSParameterAssert([obj isKindOfClass:[clazz class]])

#import "LIFELogger.h"
#import "LIFELocalizedStringProvider.h"

#define LIFELogExtDebug(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#define LIFELogExtInfo(fmt, ...) NSLog(fmt, ##__VA_ARGS__)

// This should *always* log to conosle
#define LIFELogExtWarn(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#define LIFELogExtError(fmt, ...) NSLog(fmt, ##__VA_ARGS__)

//////////////////////////////////////////////////
// Helper macros for model object serialization //
//////////////////////////////////////////////////

#define LIFE_DECODE_OBJECT_FOR_KEY(key) self.key = [coder decodeObjectForKey:NSStringFromSelector(@selector(key))]
#define LIFE_ENCODE_OBJECT_FOR_KEY(key) [coder encodeObject:self.key forKey:NSStringFromSelector(@selector(key))]
#define LIFE_STRING_FROM_SELECTOR_NAMED(selector_name) NSStringFromSelector(@selector(selector_name))

//////////////////////////
// Swiftier Objective-C //
//////////////////////////

#if defined(__cplusplus)
#define let auto const
#else
#define let const __auto_type
#endif

#if defined(__cplusplus)
#define var auto
#else
#define var __auto_type
#endif

//////////////////////////////////////////////////
// Demo mode stuff                              //
//////////////////////////////////////////////////

#define LIFE_DEMO_MODE false

#if LIFE_DEMO_MODE
#warning YOU ARE IN DEMO MODE
#warning DO NOT SHIP THIS
#warning SERIOUSLY DON'T SHIP THIS
#endif

#endif /* LIFEMacros_h */
