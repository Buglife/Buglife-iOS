//
//  NSArray+LIFEAdditions.h
//  Pods
//
//  Created by David Schukin on 5/17/16.
//
//

#import <Foundation/Foundation.h>

void LIFELoadCategoryFor_NSArrayLIFEAdditions(void);

@interface NSArray<ObjectType> (LIFEAdditions)

- (nonnull NSArray *)life_map:(id __nonnull (^ __nonnull)(ObjectType __nonnull obj))block;
- (nonnull NSArray *)life_arrayFilteredToObjectsOfClass:(__nonnull Class)aClass;
- (nonnull NSArray *)life_filteredArrayUsingBlock:(BOOL (^ __nonnull)(ObjectType __nonnull obj))block;
- (nullable ObjectType)life_firstObjectMatchingBlock:(BOOL (^ __nonnull)(ObjectType __nonnull obj))block;

@end
