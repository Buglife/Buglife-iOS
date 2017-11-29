//
//  UIDevice+LIFEAdditions.h
//  Pods
//
//  Created by David Schukin on 12/13/16.
//
//

#import <UIKit/UIKit.h>
#import "LIFECategories.h"

@interface UIDevice (LIFEAdditions)

- (BOOL)life_isSimulator;

@end

LIFE_CATEGORY_FUNCTION_DECL(UIDevice);
