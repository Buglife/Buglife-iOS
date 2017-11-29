//
//  UIWindow+LIFEAdditions.h
//  Pods
//
//  Created by David Schukin on 11/4/15.
//
//

#import <UIKit/UIKit.h>

@class Buglife;

@interface LIFEUIWindow : NSObject

+ (void)monkeyPatchMotionEndedForBuglife:(Buglife *)buglife;

@end
