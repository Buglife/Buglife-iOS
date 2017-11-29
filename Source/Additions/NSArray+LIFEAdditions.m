//
//  NSArray+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 5/17/16.
//
//

#import "NSArray+LIFEAdditions.h"

@implementation NSArray (LIFEAdditions)

+ (void)life_loadCategory_NSArrayLIFEAdditions { }

- (NSArray *)life_map:(id (^)(id obj))block
{
    NSParameterAssert(block != nil);
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj);
        
        if (value) {
            [result addObject:value];
        }
    }];
    
    return [NSArray arrayWithArray:result];
}

- (NSArray *)life_arrayFilteredToObjectsOfClass:(Class)aClass
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:aClass];
    }];
    
    return [self filteredArrayUsingPredicate:predicate];
}

- (nonnull NSArray *)life_filteredArrayUsingBlock:(BOOL (^)(id obj))block
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return block(evaluatedObject);
    }];

    return [self filteredArrayUsingPredicate:predicate];
}

- (nullable id)life_firstObjectMatchingBlock:(BOOL (^)(id obj))block
{
    NSArray *matchingObjects = [self life_filteredArrayUsingBlock:block];
    return matchingObjects.firstObject;
}

@end

void LIFELoadCategoryFor_NSArrayLIFEAdditions() {
    [NSArray life_loadCategory_NSArrayLIFEAdditions];
}
