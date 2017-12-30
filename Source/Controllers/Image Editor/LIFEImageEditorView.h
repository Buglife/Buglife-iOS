//
//  LIFEImageEditorView.h
//  Buglife
//
//  Created by David Schukin on 12/28/17.
//

#import <UIKit/UIKit.h>

@class LIFEAnnotatedImage;
@class LIFEScreenshotAnnotatorView;

@interface LIFEImageEditorView : UIView

- (nonnull instancetype)initWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage;

- (nonnull LIFEScreenshotAnnotatorView *)screenshotAnnotatorView;

@end
