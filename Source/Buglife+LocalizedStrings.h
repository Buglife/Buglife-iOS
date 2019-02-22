//
//  Buglife+LocalizedStrings.h
//  Buglife
//
//  Copyright (c) 2017 Buglife, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Buglife.h"

#define LIFEStringKey static NSString * __nonnull const

LIFEStringKey LIFEStringKey_Cancel = @"Cancel";
LIFEStringKey LIFEStringKey_OK = @"OK";
LIFEStringKey LIFEStringKey_Done = @"Send";
LIFEStringKey LIFEStringKey_Next = @"Next";
LIFEStringKey LIFEStringKey_ReportABug = @"Send Feedback";
LIFEStringKey LIFEStringKey_Delete = @"Delete";
LIFEStringKey LIFEStringKey_ArrowToolLabel = @"Point"; // Tool labels should be verbs
LIFEStringKey LIFEStringKey_LoupeToolLabel = @"Zoom"; // Tool labels should be verbs
LIFEStringKey LIFEStringKey_BlurToolLabel = @"Blur"; // Tool labels should be verbs
LIFEStringKey LIFEStringKey_FreeformToolLabel = @"Draw";
LIFEStringKey LIFEStringKey_DeleteArrow = @"Delete Arrow";
LIFEStringKey LIFEStringKey_DeleteLoupe = @"Delete Loupe";
LIFEStringKey LIFEStringKey_DeleteBlur = @"Delete Blur";
LIFEStringKey LIFEStringKey_Report = @"Feedback";
LIFEStringKey LIFEStringKey_UserEmailInputFieldTitle = @"Your email";
LIFEStringKey LIFEStringKey_UserEmailInputFieldPlaceholder = @"name@example.com";
LIFEStringKey LIFEStringKey_SummaryInputFieldTitle = @"Feedback";
LIFEStringKey LIFEStringKey_SummaryInputFieldDetailedTitle = @"What Happened?";
LIFEStringKey LIFEStringKey_SummaryInputFieldPlaceholder = @"Give us some feedback.";
LIFEStringKey LIFEStringKey_SummaryInputFieldDetailedPlaceholder = @"Provide a summary of your report.";
LIFEStringKey LIFEStringKey_SummaryInputFieldAccessibilityHint = @"Text entered here is submitted with your feedback.";
LIFEStringKey LIFEStringKey_SummaryInputFieldAccessibilityDetailedHint = @"Text entered here is submitted with the bug report.";
LIFEStringKey LIFEStringKey_StepsToReproduce = @"Steps to Reproduce";
LIFEStringKey LIFEStringKey_ExpectedResults = @"Expected Results";
LIFEStringKey LIFEStringKey_ExpectedResultsPlaceholder = @"Describe what you expected to happen.";
LIFEStringKey LIFEStringKey_ActualResults = @"Actual Results";
LIFEStringKey LIFEStringKey_ActualResultsPlaceholder = @"Describe what actually happened.";
LIFEStringKey LIFEStringKey_HideUntilNextLaunch = @"Hide until next launch";
LIFEStringKey LIFEStringKey_DontAskUntilNextLaunch = @"Don't ask until next launch";
LIFEStringKey LIFEStringKey_HelpUsMakeXYZBetter = @"Help us make %@ better!";
LIFEStringKey LIFEStringKey_HelpUsMakeThisAppBetter = @"Help us make this app better!";
LIFEStringKey LIFEStringKey_ReportABugWithScreenRecording = @"Submit feedback with that screen recording?";
LIFEStringKey LIFEStringKey_ThanksForFilingABug = @"Thanks for sending us feedback!";
LIFEStringKey LIFEStringKey_Attachments = @"Attachments";
LIFEStringKey LIFEStringKey_AttachPhoto = @"Attach Photo";
LIFEStringKey LIFEStringKey_Arrow = @"Arrow";
LIFEStringKey LIFEStringKey_ArrowAccessibilityValue = @"Head is pointing %.0f pixels from the top and %.0f pixels from the left";
LIFEStringKey LIFEStringKey_Blur = @"Blur";
LIFEStringKey LIFEStringKey_Loupe = @"Magnification loupe";
LIFEStringKey LIFEStringKey_LoupeAccessibilityLabel = @"Magnification loupe";
LIFEStringKey LIFEStringKey_LoupeAccessibilityValue = @"Centered at pixel coordinates %.0f by %.0f, and is %.0f pixels wide by %.0f pixels tall";
LIFEStringKey LIFEStringKey_Component = @"Component";
LIFEStringKey LIFEStringKey_DiscardReportAlertTitle = @"Discard this feedback?";
LIFEStringKey LIFEStringKey_DiscardReportAlertMessage = @"All data for this report will be discarded... But you can always report feedback later!";
LIFEStringKey LIFEStringKey_DiscardReportAlertConfirm = @"Discard";
LIFEStringKey LIFEStringKey_DiscardReportAlertCancel = @"Nevermind";

LIFEStringKey LIFEStringKey_GenericAlertTitle = @"Oops!";
LIFEStringKey LIFEStringKey_InvalidEmailAlertMessage = @"\"%@\" is not a valid email address.";
LIFEStringKey LIFEStringKey_ReportSubmissionErrorAlertTitle = @"We were unable to submit your feedback.";
LIFEStringKey LIFEStringKey_ReportSubmissionErrorAlertMessage = @"This may be caused by poor network connectivity. Please try again.";

/**
 *  Strings used in the Buglife reporter UI are translated to 15+ languages,
 *  however in some cases you may choose to override strings for your application.
 *  For example, you may choose to present the reporter as a "feedback" form,
 *  thus changing all instances of the word "bug" to "feedback". You can do
 *  so via your application's Localizable.strings implementation(s).
 *
 *  To customize a Buglife string, simply use the corresponding key identifier
 *  from the list above as your Localizable.strings key. For example:
 *
 *    // Localizable.strings
 *    // MyApp
 *
 *    "LIFEStringKey_ReportABug" = "Report Feedback";
 *    "LIFEStringKey_ThanksForFilingABug" = "Thanks for submitting feedback!";
 *    // <Other localized strings for your application follow>
 *
 */
@interface Buglife (LocalizedStrings)

/**
 *  Set this property to `true` to show Buglife string keys in the 
 *  bug reporter flow that haven't been overridden by your application.
 *
 *  By default, this property returns `false`.
 *
 *  @warning This property should only be used for debugging.
 */
@property (nonatomic) BOOL showStringKeys;

@end
