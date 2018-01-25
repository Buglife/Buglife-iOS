//
//  UIControl+LIFEAdditons.m
//  Copyright (C) 2018 Buglife, Inc.
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

#import "UIControl+LIFEAdditions.h"
#import "LIFEMacros.h"
#import <objc/runtime.h>
#import "LIFEAwesomeLogger+Protected.h"
#import "LIFEContextAwareLogFormatter.h"
#import "Buglife.h"


@implementation UIControl (LIFEAdditions)
LIFE_CATEGORY_METHOD_IMPL(UIControl)

+ (void)life_swizzleSendAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (Buglife.sharedBuglife.captureUserEventsEnabled) {
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                
                Method m = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
                if (method_getImplementation(m) == (IMP)life_sendActionImp)
                {
                    return;
                }
                __originalSendActionImp = method_setImplementation(m, (IMP)life_sendActionImp);
            });
        }
    });
}
+ (void)load
{
    [self life_swizzleSendAction];
}
static IMP __originalSendActionImp;
static void life_sendActionImp(id self, SEL _cmd, SEL action, id target, UIEvent *event)
{
    if (Buglife.sharedBuglife.captureUserEventsEnabled)
    {
        if ([self isKindOfClass:[UIButton class]])
        {
            if ([[self titleLabel].text isEqualToString:@""])
            {
                [LIFEAwesomeLogger.sharedLogger _logDebugMessage:[NSString stringWithFormat:@"Button tapped: %@", self] context:LIFELogContextUserEvent];
            }
            else
            {
                [LIFEAwesomeLogger.sharedLogger _logDebugMessage:[NSString stringWithFormat:@"Button tapped: %@", [self titleLabel].text] context:LIFELogContextUserEvent];

            }
        }
        //UISegmentedContrl
        //UISlider
        //UISwitch
        //UIDatePicker
        //UIPageControl
        //UITextField
        /* //Turn these back on as they're tested.
         else if ([self isKindOfClass:[UIPageControl class]])
         {
         UIPageControl *pcSelf = (UIPageControl *)self;
         LIFELogDebug(@"Page control activated. Current Page: %zd, number of pages: %zd", pcSelf.currentPage, pcSelf.numberOfPages);
         }
         else if ([self isKindOfClass:[UISwitch class]])
         {
         UISwitch *switchSelf = (UISwitch *)self;
         LIFELogDebug(@"Switch toggled to: %@", switchSelf.on ? @"ON" : @"OFF");
         }
         else if ([self isKindOfClass:[UISegmentedControl class]])
         {
         UISegmentedControl *scSelf = (UISegmentedControl *)self;
         LIFELogDebug(@"Segmented control index selected: %zd", scSelf.selectedSegmentIndex);
         }
         */
        else
        {
            //Uncomment this if you want logging on all UIControl activations
            // It looks like this:
            /*
             Got an action: _invoke:forEvent:, target: <_UIButtonBarTargetAction: 0x608000033860>, event: <UITouchesEvent: 0x60000011aa60> timestamp: 1952.22 touches: {(
             <UITouch: 0x7fcd37641500> phase: Ended tap count: 1 force: 0.000 window: <LIFEContainerWindow: 0x7fcd3a915a30; baseClass = UIWindow; frame = (0 0; 375 667); gestureRecognizers = <NSArray: 0x60000024fff0>; layer = <UIWindowLayer: 0x60000023ca40>> view: <_UIButtonBarButton: 0x7fcd3752bb10; frame = (0 0; 49 44); tintColor = UIExtendedSRGBColorSpace 0 0.85098 0.780392 1; layer = <CALayer: 0x608000033140>> location in window: {350, 45} previous location in window: {350, 45} location in view: {32, 25} previous location in view: {32, 25}
             )}
             */
            //[LIFEAwesomeLogger.sharedLogger _logDebugMessage:[NSString stringWithFormat:@"Got an action: %@, target: %@, event: %@", NSStringFromSelector(action), target, event] context:LIFELogContextUserEvent];
        }
    }
    ((void(*)(id,SEL,SEL,id,UIEvent*))(__originalSendActionImp))(self, _cmd, action, target, event);
}


@end
LIFE_CATEGORY_FUNCTION_IMPL(UIControl);
