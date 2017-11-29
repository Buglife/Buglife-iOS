//
//  UIApplication+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 9/20/15.
//
//

#import "UIApplication+LIFEAdditions.h"
#import "UIImage+LIFEAdditions.h"
#import "UIView+LIFEAdditions.h"
#import "LIFEMacros.h"
#import "Buglife.h"
#import "LIFEBugButtonWindow.h"
#import "LIFECompatibilityUtils.h"

#if LIFE_DEMO_MODE
#import "LIFEReportWindow.h"
#endif

// This is just `UITextEffectsWindow` encoded in bas64
static NSString * const kHackedClassBase64 = @"VUlUZXh0RWZmZWN0c1dpbmRvdw==";

@implementation LIFEUIApplication

+ (UIImage *)life_screenshot
{
    return [self life_screenshotAfterScreenUpdates:YES];
}

+ (UIImage *)life_screenshotAfterScreenUpdates:(BOOL)afterScreenUpdates
{
    // Create a graphics context with the target size
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray<__kindof UIWindow *> *windows = [self life_windowsForScreenshot];
    
    // First, check & warn the user if any windows have the same windowLevel
    {
        UIWindow *previousWindow;
        
        for (UIWindow *window in windows) {
            if (previousWindow && LIFEWindowLevelsEqual(previousWindow.windowLevel, window.windowLevel)) {
                NSMutableString *windowString = [NSMutableString string];
                
                for (UIWindow *logWindow in windows) {
                    [windowString appendFormat:@"<%@: %p; windowLevel = %@>\n", NSStringFromClass([logWindow class]), logWindow, @(logWindow.windowLevel)];
                }
                
                LIFELogExtWarn(@"Buglife Warning: Application contains multiple visible UIWindow objects with equal windowLevel values. This behavior is undefined (see documentation for UIApplication.windows). Z-ordering of windows captured in Buglife screenshot is not guaranteed to match the visual Z-ordering prior to capturing screenshot.\n\nWindows =\n%@", windowString);
                break;
            }
            
            previousWindow = window;
        }
    }
    
    LIFELogIntDebug(@"Capturing %@ windows: %@", @(windows.count), windows);
    
    // Iterate over every window from back to front
    for (UIWindow *window in windows) {
        // -[CALayer renderInContext:] renders in the coordinate space of the layer,
        // so we must first apply the layer's geometry to the graphics context
        CGContextSaveGState(context);
        // Center the context around the window's anchor point
        CGContextTranslateCTM(context, [window center].x, [window center].y);
        // Apply the window's transform about the anchor point
        CGContextConcatCTM(context, [window transform]);
        // Offset by the portion of the bounds left of and above the anchor point
        CGContextTranslateCTM(context, -[window bounds].size.width * [[window layer] anchorPoint].x, -[window bounds].size.height * [[window layer] anchorPoint].y);
        
        // In iOS 11 beta 3, UITextEffectsWindow renders a black screen when using -drawViewHierarchyInRect:
        // so we work around this by using -renderInContext instead
        BOOL doesWindowRequireRenderInContextWorkaround = NO;

        if ([LIFECompatibilityUtils isiOS11OrHigher]) {
            NSString *className = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:kHackedClassBase64 options:0] encoding:NSUTF8StringEncoding];
            
            if ([window isKindOfClass:NSClassFromString(className)]) {
                doesWindowRequireRenderInContextWorkaround = YES;
                LIFELogIntDebug(@"Found instance of %@, which requires -renderInContext instead of -drawViewHierarchyInRect", window);
            }
        }
        
        // Render the layer hierarchy to the current context
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)] && !doesWindowRequireRenderInContextWorkaround) {
            BOOL drawn = [window drawViewHierarchyInRect:[window bounds] afterScreenUpdates:afterScreenUpdates];
            NSParameterAssert(drawn);

            if (drawn == NO) {
                LIFELogExtError(@"Buglife error: Unable to render window %@ for screen capture.", LIFEDebugDescription(window));
            }
        } else {
            [[window layer] renderInContext:context];
        }
    
        // Restore the context
        CGContextRestoreGState(context);
        
        UIImage *currentWindowImage = UIGraphicsGetImageFromCurrentImageContext();
        NSArray<LIFEBlurrableView> *blurrableViews = [window life_blurrableViews];
        
        for (id<LIFEBlurrableView> blurrableView in blurrableViews) {
            CGRect bounds = blurrableView.bounds;
            CGRect convertedRect = [blurrableView convertRect:bounds toCoordinateSpace:window.screen.fixedCoordinateSpace];
            
            UIImage *blurredWindowImage = [LIFEUIImage image:currentWindowImage pixelatedImageWithAmount:LIFEDefaultBlurAmount];
            UIImage *croppedBlurredImage = [LIFEUIImage image:blurredWindowImage croppedToRect:convertedRect];
            [croppedBlurredImage drawInRect:convertedRect];
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (NSArray<__kindof UIWindow *> *)life_windowsForScreenshot
{
    NSArray<__kindof UIWindow *> *allWindows = [[UIApplication sharedApplication] windows];
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    NSPredicate *windowPredicate = [NSPredicate predicateWithBlock:^BOOL(UIWindow *evaluatedWindow, NSDictionary *bindings) {
        if (evaluatedWindow.hidden) {
            return NO;
        }
        
        if ([evaluatedWindow isKindOfClass:[LIFEBugButtonWindow class]]) {
            return NO;
        }
        
#if LIFE_DEMO_MODE
        // Don't include the hovering touch view in screenshots
        if ([window isKindOfClass:[LIFEReportWindow class]]) {
            return NO;
        }
#endif

        return (evaluatedWindow.screen == mainScreen);
    }];
    
    return [allWindows filteredArrayUsingPredicate:windowPredicate];
}

static BOOL LIFEWindowLevelsEqual(UIWindowLevel windowLevel1, UIWindowLevel windowLevel2) {
    return (fabs(windowLevel1 - windowLevel2) < 0.1);
}

@end
