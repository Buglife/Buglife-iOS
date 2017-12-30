//
//  LIFEImageEditorViewController.h
//  Buglife
//
//  Created by David Schukin on 12/21/17.
//

#import <UIKit/UIKit.h>

@class LIFEScreenshotContext;

/**
 * Replacement for LIFEScreenshotAnnotatorViewController.
 */
@interface LIFEImageEditorViewController : UIViewController

- (nonnull instancetype)initWithScreenshot:(nonnull UIImage *)screenshot context:(nullable LIFEScreenshotContext *)context;

- (_Null_unspecified instancetype)init NS_UNAVAILABLE;
- (_Null_unspecified instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;

@end
