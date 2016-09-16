//
//  LIFEInputField.h
//  Buglife
//
//  Copyright (c) 2016 Buglife, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Facilitates appearance & behavior configuration of input fields in the bug reporter form.
 *
 * Instances of this class should be accessed via the properties on the shared `Buglife` singleton.
 * At the moment, the only input field supporting this is `userEmailField`.
 *
 * @see `Buglife.userEmailField`
 */
@interface LIFEInputField : NSObject

/**
 * Returns YES if this is a required field.
 * The value of this property is ignored if the
 * `visible` property returns NO.
 */
@property (nonatomic, getter=isRequired) BOOL required;

/**
 * Returns YES if this field is visible to the user.
 */
@property (nonatomic, getter=isVisible) BOOL visible;

@end
