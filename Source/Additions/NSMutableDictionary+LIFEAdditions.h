//
//  NSMutableDictionary+LIFEAdditions.h
//  Pods
//
//  Created by David Schukin on 11/26/15.
//
//

#import <Foundation/Foundation.h>

/**
 Deprecated; Created this before I realized I could load categories. Derp.
 */
@interface LIFENSMutableDictionary<KeyType, ObjectType> : NSObject

- (nonnull instancetype)initWithSubject:(nullable NSMutableDictionary *)subject;

- (void)life_safeSetObject:(ObjectType _Nonnull)object forKey:(KeyType <NSCopying> _Nonnull)key;

@end

#define LIFENSMutableDictionaryify(view) [[LIFENSMutableDictionary alloc] initWithSubject:view]

void LIFELoadCategoryFor_NSMutableDictionaryLIFEAdditions(void);

@interface NSMutableDictionary<KeyType, ObjectType> (LIFEAdditions)

- (void)life_safeSetObject:(ObjectType _Nonnull)object forKey:(KeyType <NSCopying> _Nonnull)key;

@end
