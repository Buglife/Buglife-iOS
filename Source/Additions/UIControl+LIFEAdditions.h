//
//  UIControl+LIFEAdditions.h
//  Buglife
//
//  Created by Daniel DeCovnick on 1/17/18.
//  Copyright © 2018 Buglife, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LIFECategories.h"

@interface UIControl (LIFEAdditions)
+ (void)swizzleSendAction;

@end

LIFE_CATEGORY_FUNCTION_DECL(UIControl)
