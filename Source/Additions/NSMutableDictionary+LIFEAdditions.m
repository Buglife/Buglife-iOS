//
//  NSMutableDictionary+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 11/26/15.
//
//

#import "NSMutableDictionary+LIFEAdditions.h"

@interface LIFENSMutableDictionary ()

@property (nonatomic) NSMutableDictionary *subject;

@end

@implementation LIFENSMutableDictionary : NSObject

- (instancetype)initWithSubject:(NSMutableDictionary *)subject
{
    self = [super init];
    if (self) {
        _subject = subject;
    }
    return self;
}

- (void)life_safeSetObject:(id)object forKey:(id<NSCopying>)key
{
    [self.subject life_safeSetObject:object forKey:key];
}

@end

@implementation NSMutableDictionary (LIFEAdditions)

+ (void)life_loadCategory_NSMutableDictionaryLIFEAdditions { }

- (void)life_safeSetObject:(id)object forKey:(id<NSCopying>)key
{
    if (object) {
        [self setObject:object forKey:key];
    }
}

@end

void LIFELoadCategoryFor_NSMutableDictionaryLIFEAdditions() {
    [NSMutableDictionary life_loadCategory_NSMutableDictionaryLIFEAdditions];
}
