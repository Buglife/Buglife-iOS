//
//  UIWindow+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 11/4/15.
//
//

#import "UIWindow+LIFEAdditions.h"
#import "Buglife+Protected.h"
#import "LIFESwizzler.h"

@implementation LIFEUIWindow

/*
 If you're wondering why we take this insane approach to swizzling, it's because
 http://petersteinberger.com/blog/2014/a-story-about-swizzling-the-right-way-and-touch-forwarding/
 */
+ (void)monkeyPatchMotionEndedForBuglife:(Buglife *)buglife
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self _monkeyPatchMotionEndedForBuglife:buglife];
    });
}

+ (void)_monkeyPatchMotionEndedForBuglife:(Buglife *)buglife
{
    __block IMP originalIMP = LIFEReplaceMethodWithBlock([UIWindow class], @selector(motionEnded:withEvent:), ^(UIWindow *_self, UIEventSubtype motion, UIEvent *event) {
        ((void ( *)(id, SEL, UIEventSubtype, UIEvent *))originalIMP)(_self, @selector(motionEnded:withEvent:), motion, event);
        [buglife life_motionEnded:motion withEvent:event];
    });
}

@end
