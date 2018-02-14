//
//  Buglife.h
//  Copyright (C) 2017 Buglife, Inc.
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

#import <UIKit/UIKit.h>
#import "LIFEAppearance.h"
#import "LIFEAwesomeLogger.h"
#import "LIFEInputField.h"
#import "LIFETextInputField.h"
#import "LIFEPickerInputField.h"

/**
 Options for automatically invocating the bug reporter view.
 This is an option set, and can be combined to simulatenously support multiple invocation types.
 */
typedef NS_OPTIONS(NSUInteger, LIFEInvocationOptions) {
    /// Does not automatically invoke the bug reporter view. Use this if you wish to only manually invoke the bug reporter.
    LIFEInvocationOptionsNone             = 0,
    /// Invokes the bug reporter by shaking the device (Ctrl+Cmnd+Z in Simulator).
    LIFEInvocationOptionsShake            = 1 << 0,
    /// Invokes the bug reporter whenever the user manually takes a screenshot (i.e. by simultaneously pressing the Home & Lock buttons on their device).
    LIFEInvocationOptionsScreenshot       = 1 << 1,
    /// Places a floating bug button on the screen, which can be moved by the user. Tapping this button invokes the bug reporter.
    LIFEInvocationOptionsFloatingButton   = 1 << 2
};

/**
 The retry policy for submitting bug reports.
 */
typedef NS_ENUM(NSUInteger, LIFERetryPolicy) {
    /// Automatically re-attempts to submit the bug report on the next cold application launch.
    /// Resubmission is done a few seconds after launch, so that your app's own network requests are prioritized.
    LIFERetryPolicyNextLaunch   = 0,
    /// Specifies that report submission is a UI-blocking operation. Submitting a bug reporter will show a loading
    /// indicator, and wait until the report has been successfully recieved by the Buglife API before dismissing
    /// the bug report UI.
    LIFERetryPolicyManualRetry
};

/**
 *  Represents a type of attachment.
 *
 *  @see `Buglife.addAttachmentWithData(_:type:filename:error:)`
 */
typedef NSString LIFEAttachmentType;

/// Text attachment type.
extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierText;
/// JSON attachment type. This can be used to attach network responses, and other JSON payloads.
extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierJSON;
/// SQLite attachment type. This can be used to attach Core Data databases, and other SQLite files.
extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierSqlite;
/// Image attachment type. This can be used to programmatically attach screenshots. The exact type (JPEG/PNG) will be inferred from the provided filename.
extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierImage;

@protocol BuglifeDelegate;

/**
 * Name of the notification sent when the reporter will be presented. 
 * The Buglife object will be posted with the notification so registered objects do not need to be referenced by the Buglife delegate.
 * Objects that receive the notification can add their own context to the report via setStringValue:forAttribute:
 *
 * View controllers interested in this notification should consider registering in viewWillAppear: and unregistering in viewDidDisappear:.
 * This way the context of both is available during a screenshot during a transition or segue, but view controllers further up the stack do not report irrelevant context.
 */
extern NSString * __nonnull const LIFENotificationWillPresentReporter;

/**
 * Name of the notification sent when the user cancels a report.
 * Objects that receive this notification may want to remove attributes previously set; they are not cleared by Buglife.
 */
extern NSString * __nonnull const LIFENotificationUserCanceledReport;

/**
 * Name of the notification sent when the user successfully submits a report
 * Objects that receive this notification may want to remove attributes previously set; they are not cleared by Buglife.
 */
extern NSString * __nonnull const LIFENotificationUserSubmittedReport;

/**
 *  Buglife! Handles initialization and configuration of Buglife.
 */
@interface Buglife : NSObject

/**
 *  A mask of options specifying the way(s) that the Buglife bug reporter window
 *  can be invoked.
 *
 *  You may choose to support multiple invocation options, e.g.:
 *
 *    [Buglife sharedBuglife].invocationOptions = LIFEInvocationOptionsShake | LIFEInvocationOptionsScreenshot;
 *
 *  This returns LIFEInvocationOptionsShake by default.
 */
@property (nonatomic) LIFEInvocationOptions invocationOptions;

/**
 *  Specifies the retry policy for submitting bug reports.
 *  This returns LIFERetryPolicyNextLaunch by default.
 */
@property (nonatomic) LIFERetryPolicy retryPolicy;

/**
 *  Returns the SDK version.
 */
@property (nonatomic, readonly, nonnull) NSString *version;

/**
 * The delegate can be used to configure various aspects of the Buglife reporter.
 */
@property (nonatomic, weak, nullable) id<BuglifeDelegate> delegate;

/**
 * Whether certain UIControl and navigation events will be logged. Defaults to `YES`
 */
@property (nonatomic) BOOL captureUserEventsEnabled;

/**
 * Whether the add additional attachments button will be displayed. Defaults to `YES`
 */
@property (nonatomic) BOOL allowsAdditionalAttachments;

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
 *  in your app delegate's `-application:didFinishLaunchingWithOptions:` method.
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
 *  `-application:didFinishLaunchingWithOptions:` method.
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
 *  @see `userEmailField`
 *
 *  @param email The current user's email address
 */
- (void)setUserEmail:(nullable NSString *)email;

/**
 *  Adds custom data to bug reports. Set a `nil` value for a given attribute to delete
 *  its current value.
 */
- (void)setStringValue:(nullable NSString *)value forAttribute:(nonnull NSString *)attribute;

/**
 *  Set this property if you'd like to use custom input fields. The bug reporter UI
 *  will display fields in this same order.
 *
 *  Setting this property will override the default fields (i.e. "What's happening").
 *  If you'd like to use default system fields, you can use the corresponding LIFEInputField
 *  constructors, and include them in your array of custom input fields.
 *
 *  Set this property to null if you'd like to simply use the default field(s).
 *  Set this property to `LIFEInputField.bugDetailInputFields()` if you want a Summary,
 *  Steps to Reproduce, Expected Resutls, and Actual Results fields. 
 */
@property (nonatomic, nullable) NSArray<LIFEInputField *> *inputFields;

/**
 *  Represents the email address input field in the bug reporter UI.
 *
 *  If your application code cannot programmatically set the user's email
 *  address at runtime via the `setUserEmail:` method, then you may choose
 *  to set this field to visible in order to ask the user for their
 *  email address prior to submitting a bug report.
 *
 *  By default, this field is neither visible nor required.
 *
 *  @see `setUserEmail(email:)`
 */
@property (nonatomic, readonly, nonnull) LIFEInputField *userEmailField;

/**
 *  Returns an appearance proxy that can be used to configure visual aspects
 *  of the bug reporter.
 */
@property (nonatomic, readonly, nonnull) id<LIFEAppearance> appearance;

/**
 *  Adds an attachment to be uploaded along with the next bug report.
 *
 *  Although you can add an attachment at any time, it is best to do so within `buglife:handleAttachmentRequestWithCompletionHandler:`.
 *  This ensures that your attachment is added once & only once for every submitted bug report.
 *
 *  This method is thread-safe.
 *
 *  @param data The attachment data.
 *  @param type The type of attachment. This must be one of the Buglife-provided LIFEAttachmentType constants.
 *  @param filename The filename that this data should assume once submitted to the Buglife API.
 *  @return whether or not the attachment succeeded.
 */
- (BOOL)addAttachmentWithData:(nonnull NSData *)data type:(nonnull LIFEAttachmentType *)type filename:(nonnull NSString *)filename error:(NSError * _Nullable * _Nullable)error;

/**
 *  Convenience method for adding an image attachment.
 *
 *  If necessary, images attached using this method may be automatically resized to fit within the 3 MB total limit for file attachments.
 *
 *  @see `addAttachmentWithData(_:type:filename:)`
 *
 *  @param image The image object to attach.
 *  @param filename The filename.
 */
- (void)addAttachmentWithImage:(nonnull UIImage *)image filename:(nonnull NSString *)filename;

/**
 *  Renders & returns a screenshot of your application.
 *
 *  This can be used to generate screenshots to manually attach when
 *  invoking the bug reporter using the `presentReporter()` method.
 */
- (nonnull UIImage *)screenshot;

/**
 *  Sorry, Buglife is a singleton 😁
 *  Please use the shared initializer `Buglife.sharedBuglife()`
 */
- (null_unspecified instancetype)init NS_UNAVAILABLE;

@end

/**
 *  The `BuglifeDelegate` protocol provides a mechanism for your application to configure
 *  certain aspects of the Buglife reporter UI.
 */
@protocol BuglifeDelegate <NSObject>
@optional

/**
 *  Buglife calls this method when the bug reporter is ready to accept attachments.
 *
 *  You should use this method to add attachments. Within your method implementation,
 *  use `Buglife.addAttachmentWithData(_:type:filename:)` to add attachments, then
 *  call the `completionHandler`. You may both add attachments & call the `completionHandler`
 *  on any thread.
 *
 *  @warning You only have a few seconds to add attachments & call the `completionHandler`.
 *           If the `completionHandler` isn't called, the bug report submission process
 *           will continue regardless.
 */
- (void)buglife:(nonnull Buglife *)buglife handleAttachmentRequestWithCompletionHandler:(nonnull void (^)(void))completionHandler;

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

/**
 *  Called when the bug report form has been completed by the user.
 *
 *  If your application uses custom input fields, then this method gives your app an opportunity
 *  to examine values submitted for these fields by the user by inspecting the `attributes` parameter.
 *
 *  @param attributes A dictionary of attributes submitted for a bug report, where the key is an attribute name (e.g. specified
 *                    by your custom input field), and the dictionary value is the attribute's corresponding value,
 *                    as inputted by the user (or its `default` value). Custom attributes set programmatically may neeed to be cleared here.
 */
- (void)buglifeDidCompleteReportWithAttributes:(nonnull NSDictionary<NSString *, NSString *> *)attributes;

/**
 *  Asks the delegate whether the "Thank you" dialog should be presented after a bug report is completed.
 *  Returning YES from this method will result in the default dialog being presented after report completion.
 *  Returning NO from this method will omit presenting any dialog. You can also use this to present your own custom completion dialog.
 */
- (BOOL)buglifeWillPresentReportCompletedDialog:(nonnull Buglife *)buglife;

/**
 *  Alert the delegate that the report was dismissed without sending the report.
 *  
 *  @param attributes A dictionary of attributes that would have been submitted for a bug report, where the key is an attribute name
 *                    (e.g. spcified by your custom input field), and the dictionary value is the attribute's corresponding value, as inputted
 *                    by the user (or its `default` value). Custom attributes set programmatically may need to be cleared here.
 */
- (void)buglife:(nonnull Buglife *)buglife userCanceledReportWithAttributes:(nonnull NSDictionary<NSString *, NSString *> *)attributes;

@end

/**
 *  `UIView` subclasses that contain potentially sensitive information may
 *  adopt this protocol so that their contents are automatically blurred
 *  whenever Buglife captures a screenshot.
 *
 *  For example, a `UIView` subclass for credit card entry should adopt this
 *  protocol so that a user's credit card is obscured prior to screenshot capturing.
 */
@protocol LIFEBlurrableView <UICoordinateSpace>

@required

/**
 *  Return YES if your view contains potentially sensitive information.
 */
- (BOOL)buglifeShouldBlurForScreenCapture;

@end

#import "Buglife+LocalizedStrings.h"
