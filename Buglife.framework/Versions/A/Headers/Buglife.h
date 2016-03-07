//
//  Buglife.h
//  Buglife
//
//  Copyright (c) 2016 Buglife, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, LIFEInvocationOptions) {
    LIFEInvocationOptionsNone             = 0,
    LIFEInvocationOptionsShake            = 1 << 0,
    LIFEInvocationOptionsScreenshot       = 1 << 1,
    LIFEInvocationOptionsFloatingButton   = 1 << 2
};

/**
 *  Buglife. Handles initialization and configuration of Buglife.
 */
@interface Buglife : NSObject

/**
 *  A mask of options specifying the way(s) that the Buglife bug reporter window
 *  can be invoked.
 *
 *  You may choose to support multiple invocation options, e.g.:
 *
 *    [Buglife sharedBuglife].invocationOptions = LIFEInvocationOptionsShake | LIFEInvocationOptionsFloatingButton;
 *
 *  This returns LIFEInvocationOptionsFloatingButton by default. We recommend the default
 *  option as-is for internal / dogfood builds, as it unobtrusively encourages users to
 *  report bugs, and does not interrupt common flows such as screenshot capturing.
 *
 *  However for App Store builds, we recommend LIFEInvocationOptionsNone. Instead,
 *  we recommend putting a button / selectable table row somewhere in your in-app settings/menu,
 *  and calling -presentReporter explicitly.
 */
@property (nonatomic) LIFEInvocationOptions invocationOptions;

/**
 *  Returns the SDK version.
 */
@property (nonatomic, readonly, nonnull) NSString *version;

/**
 *  Default shared initializer that returns the Buglife singleton.
 *
 *  @return The shared Buglife singleton
 */
+ (nonnull instancetype)sharedBuglife;

/**
 *  Enables Buglife bug reporting within your app.
 *
 *  The recommended way to enable Buglife is to call this method
 *  in your app delegate's -application:didFinishLaunchingWithOptions: method.
 *  Don't worry, it won't impact your app's launch performance. 😉
 *
 *  @param apiKey The Buglife API Key for your organization
 */
- (void)startWithAPIKey:(nonnull NSString *)apiKey;

/**
 *  Enables Buglife bug reporting within your app.
 *
 *  Call this method with your own email address if you'd like to try out Buglife without signing
 *  up for an account. Bug reports will be sent directly to the provided email.
 *
 *  This method should be called from within your app delegate's
 *  -application:didFinishLaunchingWithOptions: method.
 *
 *  @param email The email address to which bug reports should be sent. This email address should
 *               belong to you or someone on your team.
 */
- (void)startWithEmail:(nonnull NSString *)email;

/**
 *  Immediately presents the Buglife bug reporter view controller.
 *  This is useful for apps that wish to supplement or replace the default invocation
 *  options, i.e. by placing a custom bug report button in their app settings.
 */
- (void)presentReporter;

/**
 *  Specifies a user identifier that will be visible in the Buglife report viewer UI.
 * 
 *  @param identifier An arbitrary string that identifies a user for your app.
 */
- (void)setUserIdentifier:(nullable NSString *)identifier;

/**
 *  Specifies an email address that will be visible in the Buglife report viewer UI.
 *
 *  This should be set to the email address of the current user, if any. For example, if your
 *  app requires users to sign in, then you may wish to use the signed in user's email address
 *  here to identify them when they submit bug reports.
 *
 *  @see setUserIdentifier:
 *
 *  @param email The current user's email address
 */
- (void)setUserEmail:(nullable NSString *)email;

/**
 *  Sorry, Buglife is a singleton 😁
 *  Please use the shared initializer +[Buglife sharedBuglife]
 */
- (nullable instancetype)init NS_UNAVAILABLE;

@end

/**
 *  UIView subclasses that contain potentially sensitive information may
 *  adopt this protocol so that their contents are automatically blurred
 *  whenever Buglife captures a screenshot.
 *
 *  For example, a UIView subclass for credit card entry should adopt this
 *  protocol so that a user's credit card is obscured prior to screenshot capturing.
 */
@protocol LIFEBlurrableView <UICoordinateSpace>

@required

/**
 *  Return YES if your view contains potentially sensitive information.
 */
- (BOOL)buglifeShouldBlurForScreenCapture;

@end
