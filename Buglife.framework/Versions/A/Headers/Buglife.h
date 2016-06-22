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

typedef NSString LIFEAttachmentType;

extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierText;
extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierJSON;
extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierSqlite;

@protocol BuglifeDelegate;

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
 * The delegate can be used to configure various aspects of the Buglife reporter.
 */
@property (nonatomic, weak, nullable) id<BuglifeDelegate> delegate;

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
 *  Adds an attachment to be uploaded along with the next bug report.
 *
 *  Although you can add an attachment at any time, it is best to do so within buglife:handleAttachmentRequestWithCompletionHandler:.
 *  This ensures that your attachment is added once & only once for every submitted bug report.
 *
 *  You may attach up to 10 files, the total size of which may be up to 3 MB.
 *  Attempting to attach more than this will result in an error
 *  (via throw in Swift, or the error out parameter in Objective-C).
 *
 *  This method is thread-safe.
 *
 *  @param attachmentData The attachment data.
 *  @param attachmentType The type of attachment. This must be one of the Buglife-provided LIFEAttachmentType constants.
 *  @param filename The filename.
 */
- (BOOL)addAttachmentWithData:(nonnull NSData *)attachmentData type:(nonnull LIFEAttachmentType *)attachmentType filename:(nonnull NSString *)filename error:(NSError * _Nullable * _Nullable)error;

/**
 *  Sorry, Buglife is a singleton 😁
 *  Please use the shared initializer +[Buglife sharedBuglife]
 */
- (nullable instancetype)init NS_UNAVAILABLE;

@end

/**
 *  The BuglifeDelegate protocol provides a mechanism for your application to configure
 *  certain aspects of the Buglife reporter UI.
 */
@protocol BuglifeDelegate <NSObject>
@optional

/**
 *  Buglife calls this method when the bug reporter is ready to accept attachments.
 *
 *  You should use this method to add attachments. Within your method implementation,
 *  use Buglife.addAttachmentWithData(_:type:filename:) to add attachments, then
 *  call the completionHandler. You may both add attachments & call the completionHandler
 *  on any thread.
 *
 *  @warning You only have a few seconds to add attachments & call the completionHandler.
 *           If the completionHandler isn't called, the bug report submission process
 *           will continue regardless.
 */
- (void)buglife:(nonnull Buglife *)buglife handleAttachmentRequestWithCompletionHandler:(nonnull void (^)())completionHandler;

/**
 *  Called when a user attempts to invoke the bug reporter UI.
 *  To prevent accidental invocations, the user is presented with a prompt before showing the full bug reporter UI.
 *  If this method is implemented by your application, the returned result is used as the title
 *  for the prompt. If the returned result is nil, the prompt does not display a title. If this method is not
 *  implemented, a default title is used.
 *
 *  @param buglife The Buglife instance requesting the title.
 *  @param invocation The invocation type used to present the bug reporter UI.
 */
- (nullable NSString *)buglife:(nonnull Buglife *)buglife titleForPromptWithInvocation:(LIFEInvocationOptions)invocation;

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


