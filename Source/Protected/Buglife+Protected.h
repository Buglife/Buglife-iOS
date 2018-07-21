//
//  Buglife+Protected.h
//  Pods
//
//  Created by David Schukin on 11/4/15.
//
//

#import "Buglife.h"

extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierPNG;
extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierJPEG;
extern LIFEAttachmentType * __nonnull const LIFEAttachmentTypeIdentifierHEIC;
extern const LIFEInvocationOptions LIFEInvocationOptionsScreenRecordingFinished;

@class LIFEBugButtonWindow;
@class LIFEContainerWindow;
@class LIFEReportOwner;
@class LIFEAttribute;
@class LIFEDataProvider;

@interface Buglife (Protected)

- (void)life_motionEnded:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event;
- (void)_presentReporterFromInvocation:(LIFEInvocationOptions)invocation withScreenshot:(nullable UIImage *)screenshot animated:(BOOL)animated;
- (void)_showContainerWindowWithViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;

#pragma mark - Testable stuff

+ (void)dispatchToMainQueue:(nonnull dispatch_block_t)block;
- (nullable UIWindow *)_applicationKeyWindow;

@property (nullable, nonatomic, readonly) LIFEBugButtonWindow *bugButtonWindow;
@property (nullable, nonatomic, readonly) NSString *apiKey;
@property (nullable, nonatomic, readonly) NSString *email;
@property (nullable, nonatomic, readonly) NSString *userIdentifier;
@property (nullable, nonatomic, readonly) NSString *userEmail;
@property (nullable, nonatomic, readonly) NSMutableDictionary<NSString *, LIFEAttribute *> *attributes;
@property (nullable, nonatomic, readonly) LIFEReportOwner *reportOwner;
@property (nonatomic, weak, null_unspecified) UIWindow *overlayWindow;
@property (nonatomic, nullable) LIFEContainerWindow *containerWindow;
@property (nonatomic) BOOL reportAlertOrWindowVisible;
@property (nonatomic, getter=isScreenRecordingInvocationEnabled) BOOL screenRecordingInvocationEnabled;
@property (null_unspecified, nonatomic, readonly) LIFEDataProvider *dataProvider;
- (nullable instancetype)initInternal;

@property (nonatomic, null_resettable) NSString *thankYouMessage;
@property (nonatomic, null_resettable) NSString *whatHappenedLabel;
@property (nonatomic, null_resettable) NSString *titleForReportViewController;
@property (nonatomic, readonly) BOOL hideUntilNextLaunchButtonEnabled;
@property (nonatomic, readonly) BOOL useLegacyReporterUI;

@end
