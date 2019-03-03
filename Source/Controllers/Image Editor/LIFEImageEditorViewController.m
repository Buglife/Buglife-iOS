//
//  LIFEImageEditorViewController.m
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
//

#import "LIFEImageEditorViewController.h"
#import "LIFEImageEditorView.h"
#import "LIFEScreenshotAnnotatorView.h"
#import "LIFEAnnotation.h"
#import "LIFEAnnotatedImage.h"
#import "LIFEArrowAnnotationView.h"
#import "LIFELoupeAnnotationView.h"
#import "LIFEBlurAnnotationView.h"
#import "LIFEFreeformAnnotationView.h"
#import "LIFEScreenshotContext.h"
#import "LIFEImageProcessor.h"
#import "LIFEMenuPopoverView.h"
#import "LIFEGeometry.h"
#import "LIFEMacros.h"
#import "LIFEImageEditorSegmentedControl.h"
#import "LIFENavigationController.h"
#import "LIFEFreeformGestureRecognizer.h"
#import "LIFEAnnotatedImageView.h"

static const CGFloat kDefaultAnnotationRotationAmount = 0.0;
static const CGFloat kDefaultAnnotationScaleAmount = 1.0;

LIFEAnnotationType LIFEAnnotationTypeFromToolButtonType(LIFEToolButtonType toolButtonType);

@interface LIFEImageEditorViewController () <UIGestureRecognizerDelegate, LIFEMenuPopoverViewDelegate>

@property (nonatomic) LIFEMutableAnnotatedImage *annotatedImage;
@property (nonatomic, null_resettable) UIBarButtonItem *cancelButton;
@property (nonatomic, null_resettable) UIBarButtonItem *nextButton;
@property (nonatomic) LIFEImageProcessor *imageProcessor;
@property (nonatomic, nullable) LIFEScreenshotContext *screenshotContext;
@property (nonatomic) BOOL statusBarHidden;
@property (null_resettable, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (null_resettable, nonatomic) LIFEFreeformGestureRecognizer *freeformGestureRecognizer;
@property (null_resettable, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) LIFEAnnotationView *annotationViewInProgress;
@property (nonatomic) NSMutableArray<UIGestureRecognizer *> *activeEditingGestureRecognizers; // Move, rotate, etc
@property (nonatomic) CGPoint previousStartPointForMovingAnnotation;
@property (nonatomic) CGPoint previousEndPointForMovingAnnotation;
@property (nonatomic) CGPoint translationForMovingAnnotation;
@property (nonatomic) CGFloat angleForRotatingAnnotation;
@property (nonatomic) CGFloat scaleForPinchingAnnotation;
@property (nonatomic, weak) LIFEAnnotationView *annotationSelectedWithPopover;

@end

@implementation LIFEImageEditorViewController

#pragma mark - Initialization

- (instancetype)initWithAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _annotatedImage = annotatedImage.mutableCopy;
        _imageProcessor = [[LIFEImageProcessor alloc] init];
        _activeEditingGestureRecognizers = [[NSMutableArray alloc] init];
        _scaleForPinchingAnnotation = kDefaultAnnotationScaleAmount;
    }
    return self;
}

- (nonnull instancetype)initWithScreenshot:(nonnull UIImage *)screenshot context:(nullable LIFEScreenshotContext *)context
{
    LIFEAnnotatedImage *annotatedImage = [[LIFEAnnotatedImage alloc] initWithScreenshot:screenshot];
    self = [self initWithAnnotatedImage:annotatedImage];
    if (self) {
        _screenshotContext = context;
        _statusBarHidden = _screenshotContext.statusBarHidden;
    }
    return self;
}

- (void)dealloc
{
    [self.view removeGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer = nil;
}

#pragma mark - UIViewController

- (void)loadView
{
    self.view = [[LIFEImageEditorView alloc] initWithAnnotatedImage:_annotatedImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.panGestureRecognizer.enabled = YES;
    self.freeformGestureRecognizer.enabled = NO;
    self.tapGestureRecognizer.enabled = YES;
    
    if (self.isInitialViewController) {
        self.navigationItem.leftBarButtonItem = self.cancelButton;
        self.navigationItem.rightBarButtonItem = self.nextButton;
    }
    
    __weak typeof(self) weakSelf = self;
    self.imageEditorView.toolDidChangeHandler = ^(LIFEToolButtonType tool) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _toolDidChange:tool];
    };
}

- (void)_toolDidChange:(LIFEToolButtonType)tool
{
    self.panGestureRecognizer.enabled = (tool != LIFEToolButtonTypeFreeform);
    self.freeformGestureRecognizer.enabled = (tool == LIFEToolButtonTypeFreeform);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationController isKindOfClass:[LIFENavigationController class]]) {
        let nav = (LIFENavigationController *)self.navigationController;
        nav.navigationBarStyleClear = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // When we add annotation views for the first time, we need
    // to first cache the various source images (i.e. blurs, loupes, etc)
    CGSize targetSize = [self _targetSizeForAnnotationViewImages];
    __weak typeof(self) weakSelf = self;
    
    [self.imageProcessor getLoupeSourceScaledImageForAnnotatedImage:self.annotatedImage targetSize:targetSize toQueue:dispatch_get_main_queue() completion:^(LIFEImageIdentifier *identifier, UIImage *result) {
        __strong LIFEImageEditorViewController *strongSelf = weakSelf;
        if (strongSelf) {
            for (LIFEAnnotation *annotation in strongSelf.annotatedImage.annotations) {
                LIFEAnnotationView *annotationView = [strongSelf _addAnnotationViewForAnnotation:annotation animated:animated];
                [strongSelf _addGestureHandlersToAnnotationView:annotationView];
            }
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // If going back to the previous view controller,
    // to notify it so that it can refresh its thumbnail
    if (!self.isInitialViewController) {
        [self _notifyDelegateOfCompletion];
    }
}

#pragma mark - Next button

- (UIBarButtonItem *)nextButton
{
    if (_nextButton == nil) {
        _nextButton = [[UIBarButtonItem alloc] initWithTitle:LIFELocalizedString(LIFEStringKey_Next) style:UIBarButtonItemStyleDone target:self action:@selector(_nextButtonTapped:)];
    }
    
    return _nextButton;
}

- (void)_nextButtonTapped:(id)sender
{
    self.cancelButton.enabled = NO;
    self.nextButton.enabled = NO;
    
    [self _notifyDelegateOfCompletion];
}

#pragma mark - Cancel button

- (UIBarButtonItem *)cancelButton
{
    if (_cancelButton == nil) {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancelButtonTapped:)];
    }
    
    return _cancelButton;
}

- (void)_cancelButtonTapped:(id)sender
{
    [self.delegate imageEditorViewControllerDidCancel:self];
}

#pragma mark - Accessors

- (LIFEImageEditorView *)imageEditorView
{
    return (LIFEImageEditorView *)self.view;
}

- (LIFEScreenshotAnnotatorView *)screenshotAnnotatorView
{
    return self.imageEditorView.screenshotAnnotatorView;
}

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_drawGestureHandler:)];
        [self.screenshotAnnotatorView.annotatedImageView addGestureRecognizer:_panGestureRecognizer];
    }
    
    return _panGestureRecognizer;
}

- (LIFEFreeformGestureRecognizer *)freeformGestureRecognizer
{
    if (_freeformGestureRecognizer == nil) {
        _freeformGestureRecognizer = [[LIFEFreeformGestureRecognizer alloc] initWithTarget:self action:@selector(_freeformGestureRecognized:)];
        _freeformGestureRecognizer.delegate = self;
        _freeformGestureRecognizer.cancelsTouchesInView = NO;
        [self.screenshotAnnotatorView.annotatedImageView addGestureRecognizer:_freeformGestureRecognizer];
    }
    
    return _freeformGestureRecognizer;
}
                                    
- (void)_freeformGestureRecognized:(nonnull LIFEFreeformGestureRecognizer *)gesture
{
    CGPoint gestureLocation = [gesture locationInView:gesture.view];
    CGSize size = gesture.view.bounds.size;
    CGVector gestureVector = LIFEVectorFromPointAndSize(gestureLocation, size);
    CGPoint gesturePoint = CGPointMake(gestureVector.dx, gestureVector.dy);
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:gesturePoint];
            LIFEAnnotation *annotation = [LIFEAnnotation freeformAnnotationWithBezierPath:path];
            LIFEAnnotationView *annotationView = [self _addAnnotationViewForAnnotation:annotation animated:NO];
            self.annotationViewInProgress = annotationView;
            [self.annotationViewInProgress setSelected:YES animated:NO];
            [self.annotatedImage addAnnotation:annotation];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            LIFEAnnotationView *annotationView = self.annotationViewInProgress;
            LIFEAnnotation *oldAnnotation = annotationView.annotation;
            UIBezierPath *path = oldAnnotation.bezierPath;
            [path addLineToPoint:gesturePoint];
            LIFEAnnotation *newAnnotation = [LIFEAnnotation freeformAnnotationWithBezierPath:path];
            annotationView.annotation = newAnnotation;
            [self.annotatedImage replaceAnnotation:oldAnnotation withAnnotation:newAnnotation];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self _addGestureHandlersToAnnotationView:self.annotationViewInProgress];
            [self.annotationViewInProgress setSelected:NO animated:YES];
            self.annotationViewInProgress = nil;
            break;
        }
        default:
            break;
    }
}

- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognized:)];
        _tapGestureRecognizer.delegate = self;
        [self.screenshotAnnotatorView.annotatedImageView addGestureRecognizer:_tapGestureRecognizer];
    }
    
    return _tapGestureRecognizer;
}

- (void)_tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    LIFEScreenshotAnnotatorView *screenshotAnnotatorView = self.imageEditorView.screenshotAnnotatorView;
    CGPoint location = [recognizer locationInView:screenshotAnnotatorView];
    LIFEAnnotationView *annotationView = [screenshotAnnotatorView annotationViewAtLocation:location];
    
    if (annotationView) {
        [self _presentPopoverForAnnotationView:annotationView];
    }
}

#pragma mark - Gesture recognizer actions

- (void)_drawGestureHandler:(UIGestureRecognizer *)gestureRecognizer
{
    LIFEAnnotationType annotationType = LIFEAnnotationTypeFromToolButtonType(self.imageEditorView.selectedTool);
    CGPoint gestureLocation = [_panGestureRecognizer locationInView:_panGestureRecognizer.view];
    CGSize size = gestureRecognizer.view.bounds.size;
    CGVector gestureVector = LIFEVectorFromPointAndSize(gestureLocation, size);
    
    switch (_panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            LIFEAnnotation *annotation = [[LIFEAnnotation alloc] initWithAnnotationType:annotationType startVector:gestureVector endVector:gestureVector];
            LIFEAnnotationView *annotationView = [self _addAnnotationViewForAnnotation:annotation animated:YES];
            
            if (annotationType == LIFEAnnotationTypeLoupe) {
                [self _updateLoupeAnnotationViews];
            }
            
            NSParameterAssert(self.annotationViewInProgress == nil);
            
            self.annotationViewInProgress = annotationView;
            [self.annotationViewInProgress setSelected:YES animated:YES];
            [self.annotatedImage addAnnotation:annotation];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            LIFEAnnotationView *annotationView = self.annotationViewInProgress;
            LIFEAnnotation *oldAnnotation = annotationView.annotation;
            LIFEAnnotation *newAnnotation = [[LIFEAnnotation alloc] initWithAnnotationType:oldAnnotation.annotationType startVector:oldAnnotation.startVector endVector:gestureVector];
            newAnnotation = [self _annotationAdjustedForMinimumAndMaximumSize:newAnnotation];
            annotationView.annotation = newAnnotation;
            [self.annotatedImage replaceAnnotation:oldAnnotation withAnnotation:newAnnotation];
            
            if (newAnnotation.annotationType == LIFEAnnotationTypeBlur) {
                [self _updateLoupeAnnotationViews];
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self _addGestureHandlersToAnnotationView:self.annotationViewInProgress];
            [self.annotationViewInProgress setSelected:NO animated:YES];
            self.annotationViewInProgress = nil;
            
            break;
        }
        default:
            break;
    }
}

- (void)_addGestureHandlersToAnnotationView:(LIFEAnnotationView *)annotationView
{
    if ([annotationView isKindOfClass:[LIFEFreeformAnnotationView class]]) {
        return;
    }
    
    // Set up edit gestures
    
    UIPanGestureRecognizer *moveGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_editAnnotationViewGestureHandler:)];
    moveGestureRecognizer.delegate = self;
    [annotationView addGestureRecognizer:moveGestureRecognizer];
    [self.freeformGestureRecognizer requireGestureRecognizerToFail:moveGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_editAnnotationViewGestureHandler:)];
    [annotationView addGestureRecognizer:pinchGestureRecognizer];
    [self.freeformGestureRecognizer requireGestureRecognizerToFail:pinchGestureRecognizer];
    
    BOOL isArrow = [annotationView isKindOfClass:[LIFEArrowAnnotationView class]];
    
    if (isArrow) {
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(_editAnnotationViewGestureHandler:)];
        rotationGestureRecognizer.delegate = self;
        [annotationView addGestureRecognizer:rotationGestureRecognizer];
        [self.freeformGestureRecognizer requireGestureRecognizerToFail:rotationGestureRecognizer];
    }
    
    // Tap-to-delete gesture
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapAnnotationViewGestureHandler:)];
    [annotationView addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.freeformGestureRecognizer requireGestureRecognizerToFail:tapGestureRecognizer];
}

- (void)_editAnnotationViewGestureHandler:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (_activeEditingGestureRecognizers.count == 0) {
                self.panGestureRecognizer.enabled = NO;
                self.annotationViewInProgress = (LIFEAnnotationView *)gestureRecognizer.view;
                [self.annotationViewInProgress setSelected:YES animated:YES];
                
                self.previousStartPointForMovingAnnotation = self.annotationViewInProgress.startPoint;
                self.previousEndPointForMovingAnnotation = self.annotationViewInProgress.endPoint;
            }
            
            if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                self.translationForMovingAnnotation = CGPointZero;
            } else if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
                self.angleForRotatingAnnotation = kDefaultAnnotationRotationAmount;
            } else if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                self.scaleForPinchingAnnotation = kDefaultAnnotationScaleAmount;
            }
            
            [_activeEditingGestureRecognizers addObject:gestureRecognizer];
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGSize size = self.annotationViewInProgress.bounds.size;
            
            if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
                self.translationForMovingAnnotation = [panGestureRecognizer translationInView:self.screenshotAnnotatorView];
            } else if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
                UIRotationGestureRecognizer *rotationGestureRecognizer = (UIRotationGestureRecognizer *)gestureRecognizer;
                self.angleForRotatingAnnotation = rotationGestureRecognizer.rotation;
            } else if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                UIPinchGestureRecognizer *pinchGestureRecognizer = (UIPinchGestureRecognizer *)gestureRecognizer;
                self.scaleForPinchingAnnotation = pinchGestureRecognizer.scale;
            }
            
            // Translate
            CGPoint translation = self.translationForMovingAnnotation;
            CGPoint startPoint = LIFECGPointAdd(self.previousStartPointForMovingAnnotation, translation);
            CGPoint endPoint = LIFECGPointAdd(self.previousEndPointForMovingAnnotation, translation);
            
            // Rotate
            CGFloat radians = self.angleForRotatingAnnotation;
            CGPoint anchor = CGPointMake((startPoint.x + endPoint.x) / 2.0, (startPoint.y + endPoint.y) / 2.0);
            startPoint = LIFECGPointApplyRotation(startPoint, anchor, radians);
            endPoint = LIFECGPointApplyRotation(endPoint, anchor, radians);

            // Scale
            CGFloat scaleAmount = self.scaleForPinchingAnnotation;
            startPoint = LIFECGPointApplyScale(startPoint, anchor, scaleAmount);
            endPoint = LIFECGPointApplyScale(endPoint, anchor, scaleAmount);
            
            // Put it all together
            CGVector startVector = LIFEVectorFromPointAndSize(startPoint, size);
            CGVector endVector = LIFEVectorFromPointAndSize(endPoint, size);
            LIFEAnnotation *oldAnnotation = self.annotationViewInProgress.annotation;
            LIFEAnnotation *newAnnotation = [[LIFEAnnotation alloc] initWithAnnotationType:self.annotationViewInProgress.annotation.annotationType startVector:startVector endVector:endVector];
            newAnnotation = [self _annotationAdjustedForMinimumAndMaximumSize:newAnnotation];
            
            self.annotationViewInProgress.annotation = newAnnotation;
            [self.annotatedImage replaceAnnotation:oldAnnotation withAnnotation:newAnnotation];
            
            // Update layers above the blur
            if ([gestureRecognizer.view isKindOfClass:[LIFEBlurAnnotationView class]]) {
                [self _updateLoupeAnnotationViews];
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [_activeEditingGestureRecognizers removeObject:gestureRecognizer];
            
            if (_activeEditingGestureRecognizers.count == 0) {
                self.panGestureRecognizer.enabled = YES;
                [self.annotationViewInProgress setSelected:NO animated:YES];
                self.annotationViewInProgress = nil;
            }
            
            if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
                self.angleForRotatingAnnotation = kDefaultAnnotationRotationAmount;
            } else if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                self.scaleForPinchingAnnotation = kDefaultAnnotationScaleAmount;
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)_tapAnnotationViewGestureHandler:(UITapGestureRecognizer *)gestureRecognizer
{
    LIFEAnnotationView *annotationView = (LIFEAnnotationView *)gestureRecognizer.view;
    [self _presentPopoverForAnnotationView:annotationView];
}

#pragma mark - Drawing

- (LIFEAnnotationView *)_addAnnotationViewForAnnotation:(LIFEAnnotation *)annotation animated:(BOOL)animated
{
    LIFEAnnotationView *annotationView;
    CGSize targetSize = [self _targetSizeForAnnotationViewImages];
    
    switch (annotation.annotationType) {
        case LIFEAnnotationTypeArrow: {
            annotationView = [[LIFEArrowAnnotationView alloc] initWithAnnotation:annotation];
            break;
        }
        case LIFEAnnotationTypeLoupe: {
            LIFELoupeAnnotationView *loupeAnnotationView = [[LIFELoupeAnnotationView alloc] initWithAnnotation:annotation];
            annotationView = loupeAnnotationView;
            
            [self.imageProcessor getLoupeSourceScaledImageForAnnotatedImage:self.annotatedImage targetSize:targetSize toQueue:dispatch_get_main_queue() completion:^(LIFEImageIdentifier *identifier, UIImage *result) {
                loupeAnnotationView.scaledSourceImage = result;
            }];
            break;
        }
        case LIFEAnnotationTypeBlur: {
            LIFEBlurAnnotationView *blurAnnotationView = [[LIFEBlurAnnotationView alloc] initWithAnnotation:annotation];
            annotationView = blurAnnotationView;
            
            [self.imageProcessor getBlurredScaledImageForImageIdentifier:self.annotatedImage.identifier sourceImage:self.annotatedImage.sourceImage targetSize:targetSize toQueue:dispatch_get_main_queue() completion:^(LIFEImageIdentifier *identifier, UIImage *result) {
                blurAnnotationView.scaledSourceImage = result;
            }];
            break;
        }
        case LIFEAnnotationTypeFreeform: {
            LIFEFreeformAnnotationView *freeformAnnotationView = [[LIFEFreeformAnnotationView alloc] initWithAnnotation:annotation];
            annotationView = freeformAnnotationView;
            break;
        }
    }
    
    [self.screenshotAnnotatorView addAnnotationView:annotationView];
    
    if (animated) {
        [self.screenshotAnnotatorView animateAddedAnnotationView:annotationView];
    }
    
    return annotationView;
}

// Loupe annotation views must be updated whenever blurs (or anything
// else underneath them) are added/removed
- (void)_updateLoupeAnnotationViews
{
    CGSize size = [self _targetSizeForAnnotationViewImages];
    LIFEScreenshotAnnotatorView *screenshotAnnotatorView = self.screenshotAnnotatorView;
    
    [self.imageProcessor clearCachedLoupeSourceScaledImagesForAnnotatedImage:self.annotatedImage targetSize:size];
    
    [self.imageProcessor getLoupeSourceScaledImageForAnnotatedImage:self.annotatedImage targetSize:size toQueue:dispatch_get_main_queue() completion:^(LIFEImageIdentifier *identifier, UIImage *result) {
        [screenshotAnnotatorView updateLoupeAnnotationViewsWithSourceImage:result];
    }];
}

#pragma mark - Annotation resizing

static const CGFloat kMinimumArrowLength = 88;
static const CGFloat kMinimumBlurWidth = 66;
static const CGFloat kMinimumBlurHeight = 44;
static const CGFloat kMinimumLoupeRadius = 44;
static const CGFloat kMaximumLoupeRadius = 150;

- (LIFEAnnotation *)_annotationAdjustedForMinimumAndMaximumSize:(LIFEAnnotation *)annotation
{
    CGSize targetSize = [self _targetSizeForAnnotationViewImages];
    LIFEAnnotationType annotationType = annotation.annotationType;
    CGVector startVector = annotation.startVector;
    CGVector endVector = annotation.endVector;
    CGPoint startPoint = LIFEPointFromVectorAndSize(startVector, targetSize);
    CGPoint endPoint = LIFEPointFromVectorAndSize(endVector, targetSize);
    CGFloat length = LIFECGPointDistance(startPoint, endPoint);
    
    switch (annotationType) {
        case LIFEAnnotationTypeArrow: {
            if (length < kMinimumArrowLength) {
                endPoint = LIFEEndpointAdjustedForDistance(startPoint, endPoint, kMinimumArrowLength);
                endVector = LIFEVectorFromPointAndSize(endPoint, targetSize);
            }
            
            return [[LIFEAnnotation alloc] initWithAnnotationType:annotationType startVector:startVector endVector:endVector];
        }
            
        case LIFEAnnotationTypeBlur: {
            if (fabs(endPoint.x - startPoint.x) < kMinimumBlurWidth) {
                if (endPoint.x > startPoint.x) {
                    endPoint.x = startPoint.x + kMinimumBlurWidth;
                } else {
                    endPoint.x = startPoint.x - kMinimumBlurWidth;
                }
            }
            
            if (fabs(endPoint.y - startPoint.y) < kMinimumBlurHeight) {
                if (endPoint.y > startPoint.y) {
                    endPoint.y = startPoint.y + kMinimumBlurHeight;
                } else {
                    endPoint.y = startPoint.y - kMinimumBlurHeight;
                }
            }
            
            endVector = LIFEVectorFromPointAndSize(endPoint, targetSize);
            
            return [[LIFEAnnotation alloc] initWithAnnotationType:annotationType startVector:startVector endVector:endVector];
        }
            
        case LIFEAnnotationTypeLoupe: {
            if (length < kMinimumLoupeRadius) {
                endPoint = LIFEEndpointAdjustedForDistance(startPoint, endPoint, kMinimumLoupeRadius);
            } else if (length > kMaximumLoupeRadius) {
                endPoint = LIFEEndpointAdjustedForDistance(startPoint, endPoint, kMaximumLoupeRadius);
            }
            
            endVector = LIFEVectorFromPointAndSize(endPoint, targetSize);
            
            return [[LIFEAnnotation alloc] initWithAnnotationType:annotationType startVector:startVector endVector:endVector];
        }
        case LIFEAnnotationTypeFreeform: {
            return annotation;
        }
    }
}

#pragma mark - Image processing

- (CGSize)_targetSizeForAnnotationViewImages
{
    return self.screenshotAnnotatorView.sourceImageView.bounds.size;
}

// MARK: UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // This ensures that an "editing" gesture (e.g. rotation/scale) doesn't
    // get recognized simultaneously with a new draw gesture. It also
    // ensures that for edit gestures to be recognized simultaenously,
    // they must be gestures on the same annotation view
    BOOL isCombiningGesturesOnAnnotationView = ([gestureRecognizer.view isKindOfClass:[LIFEAnnotationView class]] && [otherGestureRecognizer.view isKindOfClass:[LIFEAnnotationView class]] && gestureRecognizer.view == otherGestureRecognizer.view);
    
    if (!isCombiningGesturesOnAnnotationView) {
        return NO;
    }
    
    BOOL isPanAndRotate = ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) || ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]);
    
    BOOL isPanAndPinch = ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) || ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]);
    
    BOOL isPinchAndRotate = ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) || ([otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]);
    
    // Allow multiple editing gestures to be combined simultaenously
    return isPanAndRotate || isPanAndPinch || isPinchAndRotate;
}

#pragma mark - LIFEMenuPopoverViewDelegate

- (void)_presentPopoverForAnnotationView:(LIFEAnnotationView *)annotationView
{
    LIFEMenuPopoverView *menu = [[LIFEMenuPopoverView alloc] init];
    menu.delegate = self;
    NSString *deleteString = LIFELocalizedString(LIFEStringKey_Delete);
    
    if ([annotationView isKindOfClass:[LIFEArrowAnnotationView class]]) {
        deleteString = LIFELocalizedString(LIFEStringKey_DeleteArrow);
    } else if ([annotationView isKindOfClass:[LIFEBlurAnnotationView class]]) {
        deleteString = LIFELocalizedString(LIFEStringKey_DeleteBlur);
    } else if ([annotationView isKindOfClass:[LIFELoupeAnnotationView class]]) {
        deleteString = LIFELocalizedString(LIFEStringKey_DeleteLoupe);
    } else if ([annotationView isKindOfClass:[LIFEFreeformAnnotationView class]]) {
        deleteString = LIFELocalizedString(LIFEStringKey_Delete);
    } else {
        NSAssert(NO, @"Unhandled annotation");
    }
    
    UIBezierPath *path = annotationView.pathForPopoverMenu;
    [menu presentPopoverFromBezierPath:path inView:self.screenshotAnnotatorView.sourceImageView withStrings:@[deleteString]];
    
    self.annotationSelectedWithPopover = annotationView;
    [self.annotationSelectedWithPopover setSelected:YES animated:YES];
}

- (void)popoverView:(LIFEMenuPopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    CGPoint arrowPoint = popoverView.arrowPoint;
    arrowPoint = [self.screenshotAnnotatorView.sourceImageView convertPoint:arrowPoint fromView:popoverView];
    CGRect deletionRect = CGRectMake(arrowPoint.x, arrowPoint.y, 1, 1);
    
    LIFEScreenshotAnnotatorView *annotatorView = self.screenshotAnnotatorView;
    LIFEAnnotationView *annotationInProgress = self.annotationSelectedWithPopover;
    self.annotationSelectedWithPopover = nil;
    
    __weak typeof(self) weakSelf = self;
    LIFEMutableAnnotatedImage *annotatedImage = self.annotatedImage;
    [annotatedImage removeAnnotation:annotationInProgress.annotation];
    
    [annotationInProgress animateToTrashCanRect:deletionRect completion:^{
        [annotatorView removeAnnotationView:annotationInProgress];
        
        // Update layers above the blur
        if ([annotationInProgress isKindOfClass:[LIFEBlurAnnotationView class]]) {
            [weakSelf _updateLoupeAnnotationViews];
        }
    }];
}

- (void)popoverViewDidDismiss:(LIFEMenuPopoverView *)popoverView
{
    [self.annotationSelectedWithPopover setSelected:NO animated:YES];
    self.annotationSelectedWithPopover = nil;
}

#pragma mark - Private methods

- (void)_notifyDelegateOfCompletion
{
    NSParameterAssert(self.delegate);
    LIFEAnnotatedImage *result = self.annotatedImage.copy;
    [self.delegate imageEditorViewController:self willCompleteWithAnnotatedImage:result];
}

@end

LIFEAnnotationType LIFEAnnotationTypeFromToolButtonType(LIFEToolButtonType toolButtonType) {
    switch (toolButtonType) {
        case LIFEToolButtonTypeArrow:
            return LIFEAnnotationTypeArrow;
        case LIFEToolButtonTypeLoupe:
            return LIFEAnnotationTypeLoupe;
        case LIFEToolButtonTypeBlur:
            return LIFEAnnotationTypeBlur;
        case LIFEToolButtonTypeFreeform:
            return LIFEAnnotationTypeFreeform;
    }
    
    NSCAssert(NO, @"Unexpected LIFEToolButtonType %@", @(toolButtonType));
    return LIFEAnnotationTypeArrow;
}
