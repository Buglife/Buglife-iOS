//
//  LIFEReportTableViewController.m
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
//

#import "LIFEReportTableViewController.h"
#import "Buglife+Protected.h"
#import "LIFEMacros.h"
#import "LIFEReportViewControllerDelegate.h"
#import "LIFEReportBuilder.h"
#import "LIFEAttachmentView.h"
#import "LIFEWhatHappenedTextView.h"
#import "LIFETextFieldCell.h"
#import "LIFEAnnotatedImage.h"
#import "LIFEScreenshotAnnotatorViewController.h"
#import "LIFEStepsToReproTableViewController.h"
#import "LIFETextInputViewController.h"
#import "LIFEReproStep.h"
#import "UIColor+LIFEAdditions.h"
#import "LIFEPoweredByBuglifeView.h"
#import "LIFEUserDefaults.h"
#import "NSArray+LIFEAdditions.h"
#import "LIFEReportAttachmentImpl.h"
#import "LIFECompatibilityUtils.h"
#import "LIFEImagePickerController.h"
#import "LIFEImageProcessor.h"
#import "LIFEGeometry.h"
#import "LIFEAppearanceImpl.h"
#import "LIFEScreenshotContext.h"
#import "LIFENotificationLogger.h"
#import "LIFEAttribute.h"
#import "LIFETextInputField.h"
#import "LIFEPickerInputField+Protected.h"
#import "LIFEInputField+Protected.h"
#import "LIFEPickerViewController.h"
#import "LIFEVideoAttachment.h"
#import "LIFERecordingShrinker.h"
#import "LIFEUserFacingAttachment.h"
#import "LIFEAVPlayerViewController.h"
#import "LIFENavigationController.h"
#import "LIFEImageEditorViewController.h"

typedef NSString LIFEInputFieldValue;

static let kUseNewImageEditor = YES;
static let kDefaultCellIdentifier = @"kDefaultCellIdentifier";
static let kPickerCellIdentifier = @"kPickerCellIdentifier";
static const CGFloat kDefaultRowHeight = 45;    // apparently this is 45 for grouped tableview style o_O
static const NSInteger kAttachmentSectionNumber = 0;
static const NSInteger kNoCurrentEditingAnnotatedImage = NSNotFound;

@interface LIFEReportTableViewController () <LIFEScreenshotAnnotatorViewControllerDelegate, LIFEWhatHappenedTextViewDelegate, LIFEStepsToReproTableViewControllerDelegate, LIFETextInputViewControllerDelegate, LIFETextFieldCellDelegate, LIFEPickerViewControllerDelegate, LIFEImageEditorViewControllerDelegate>

@property (nonatomic, nullable) LIFEScreenshotContext *screenshotContext;
@property (nonatomic) LIFEImageProcessor *imageProcessor;
@property (nonatomic) LIFEImagePickerController *imagePickerController;
@property (nonatomic) LIFEReportBuilder *reportBuilder;
@property (nonatomic) NSInteger indexOfCurrentEditingAnnotatedImage; // kNoCurrentEditingAnnotatedImage if nothing
@property (nonatomic) UIBarButtonItem *doneButton;
@property (nonatomic) NSMutableDictionary<LIFEInputField *, NSString *> *inputFieldValues;
@property (nonatomic) NSArray<LIFEReproStep *> *reproSteps;
@property (nonatomic, copy) NSString *expectedResults;
@property (nonatomic, copy) NSString *actualResults;

@property (nonatomic, weak) UIViewController *expectedResultsViewController;
@property (nonatomic, weak) UIViewController *actualResultsViewController;

@property (nonatomic, nonnull) NSMutableDictionary<LIFEInputField *, NSNumber *> *inputFieldRowHeightCache;
@property (nonatomic, getter=isDirty) BOOL dirty;

@end

@interface LIFEReportTableViewController (AddAttachments) <LIFEImagePickerControllerDelegate>

@property (nonatomic, readonly) BOOL addAttachmentsButtonEnabled;
- (void)_presentAddAttachmentControllerAnimated:(BOOL)animated;
- (void)_logWarningIfPhotoLibraryUsageDescriptionRequiredAndMissing;

@end

@implementation LIFEReportTableViewController
{
    NSArray<LIFEInputField *> *_inputFields;
    BOOL _hasAppearedAtLeastOnce;
    BOOL _allowsAdditionalAttachments;
}

- (nonnull instancetype)initWithReportBuilder:(nonnull LIFEReportBuilder *)reportBuilder
{
    return [self initWithReportBuilder:reportBuilder context:nil];
}

- (instancetype)initWithReportBuilder:(LIFEReportBuilder *)reportBuilder context:(nullable LIFEScreenshotContext *)context
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _inputFieldRowHeightCache = [[NSMutableDictionary alloc] init];
        _inputFields = [Buglife sharedBuglife].inputFields.copy;
        _allowsAdditionalAttachments = [Buglife sharedBuglife].allowsAdditionalAttachments;
        _screenshotContext = context;
        _imageProcessor = [[LIFEImageProcessor alloc] init];
        _imagePickerController = [[LIFEImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _reportBuilder = reportBuilder;
        _reproSteps = @[];
        
        _indexOfCurrentEditingAnnotatedImage = kNoCurrentEditingAnnotatedImage;
        _hasAppearedAtLeastOnce = NO;
        
        // Set default values for input fields
        _inputFieldValues = [[NSMutableDictionary alloc] init];
        
        // Map attribute values that were programmatically set, to
        // fields that were programmatically configured
        NSDictionary<NSString *, LIFEAttribute *> *attributes = [Buglife sharedBuglife].attributes.copy;
        
        for (LIFEInputField *inputField in _inputFields) {
            if (inputField.isUserEmailField) {
                // If the userEmailField is enabled, then get the value using
                // 1. the last submitted value, or
                // 2. the programmatically set userEmail (this takes priority)
                NSString *lastSubmittedUserEmail = [LIFEUserDefaults sharedDefaults].lastSubmittedUserEmailFieldValue;
                
                if (lastSubmittedUserEmail.length > 0) {
                    _inputFieldValues[inputField] = lastSubmittedUserEmail;
                } else {
                    NSString *programmaticallyConfiguredEmail = [Buglife sharedBuglife].userEmail;
                    
                    if (programmaticallyConfiguredEmail.length > 0) {
                        _inputFieldValues[inputField] = programmaticallyConfiguredEmail;
                    }
                }
            } else if (inputField.isSummaryField) {
                continue;
            } else {
                NSString *attributeName = inputField.attributeName;
                LIFEAttribute *attribute = attributes[attributeName];
                
                if (attribute) {
                    NSString *stringValue = attribute.stringValue;
                    _inputFieldValues[inputField] = stringValue;
                }
            }
        }
    }
    return self;
}

#pragma mark - Screen recording

- (void)addLastVideoAsAttachment
{
    [LIFEImagePickerController requestAuthorization:^(LIFE_PHAuthorizationStatus status) {
        if (status == LIFE_PHAuthorizationStatusAuthorized) {
            [LIFEImagePickerController getLastVideoToQueue:dispatch_get_main_queue() WithCompletion:^(NSURL * _Nullable url, NSString * _Nullable filename, NSString * _Nullable uniformTypeIdentifier) {
                LIFEVideoAttachment *video = [[LIFEVideoAttachment alloc] initWithFileURL:url uniformTypeIdentifier:uniformTypeIdentifier filename:filename isProcessing:YES];
                [self.reportBuilder addVideoAttachment:video];
            }];
        } else {
            let alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"To attach screen recordings, we need permission to access your photos." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_OK) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

#pragma mark - UIViewController stuff

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [Buglife sharedBuglife].titleForReportViewController;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LIFELocalizedString(LIFEStringKey_Report) style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancelButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    [self.tableView registerClass:[LIFEAttachmentCell class] forCellReuseIdentifier:[LIFEAttachmentCell defaultIdentifier]];
    [self.tableView registerClass:[LIFETextFieldCell class] forCellReuseIdentifier:[LIFETextFieldCell defaultIdentifier]];
    [self.tableView registerClass:[LIFEWhatHappenedTableViewCell class] forCellReuseIdentifier:[LIFEWhatHappenedTableViewCell defaultIdentifier]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDefaultCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kPickerCellIdentifier];
    
    self.tableView.tableFooterView = [[LIFEPoweredByBuglifeView alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_imagesDidChangeNotification:) name:LIFEReportBuilderAnnotatedImagesDidChangeNotification object:nil];
    
    [self _logWarningIfPhotoLibraryUsageDescriptionRequiredAndMissing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationController isKindOfClass:[LIFENavigationController class]]) {
        let nav = (LIFENavigationController *)self.navigationController;
        nav.navigationBarStyleClear = NO;
    }
}

- (void)_imagesDidChangeNotification:(NSNotification *)notification
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:kAttachmentSectionNumber];
    self.doneButton.enabled = !self._attachmentsStillProcessing;
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)_attachmentsStillProcessing
{
    for (id<LIFEUserFacingAttachment> attachment in self.userFacingAttachments) {
        if ([attachment isKindOfClass:[LIFEVideoAttachment class]]) {
            LIFEVideoAttachment *videoAttachment = (LIFEVideoAttachment *)attachment;
            
            if (videoAttachment.isProcessing) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LIFEReportBuilderAnnotatedImagesDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_hasAppearedAtLeastOnce == NO) {
        [self _makeNextEmptyFieldFirstResponder];
        _hasAppearedAtLeastOnce = YES;
    }
}

#pragma mark - UIViewController status bar appearance

- (BOOL)prefersStatusBarHidden
{
    if (self.screenshotContext != nil) {
        return self.screenshotContext.statusBarHidden;
    } else {
        return [super prefersStatusBarHidden];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.screenshotContext != nil) {
        return self.screenshotContext.statusBarStyle;
    } else {
        return [super preferredStatusBarStyle];
    }
}

#pragma mark - UIResponder stuff

// This should invoke -becomeFirstResponder on either the email cell,
// or the What Happened cell, whichever comes first.
- (BOOL)_makeNextEmptyFieldFirstResponder
{
//    NSIndexPath *topIndexPath;
//    
//    // If the email field is hidden, or it already has text, skip to the what happened cell
//    if (_emailFieldEnabled && self.userInputtedEmail.length < 1) {
//        topIndexPath = [self _indexPathForEmailCell];
//    } else {
//        topIndexPath = [self _indexPathForWhatHappenedCell];
//    }
//    
//    NSParameterAssert(topIndexPath != nil);
//    
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:topIndexPath];
//    return [cell becomeFirstResponder];
    
    // TODO: this
    return NO;
}

#pragma mark - Done Button

- (nullable LIFEInputField *)_summaryInputField
{
    return [_inputFields life_firstObjectMatchingBlock:^BOOL(LIFEInputField *inputField) {
        return inputField.isSummaryField;
    }];
}

- (nullable LIFEInputField *)_userEmailInputField
{
    return [_inputFields life_firstObjectMatchingBlock:^BOOL(LIFEInputField *inputField) {
        return inputField.isUserEmailField;
    }];
}

- (nullable NSString *)_summaryInputFieldValue
{
    return [self _currentValueForInputField:[self _summaryInputField]];
}

- (nullable NSString *)_userEmailInputFieldValue
{
    return [self _currentValueForInputField:[self _userEmailInputField]];
}

- (nullable NSString *)_currentValueForInputField:(nullable LIFEInputField *)inputField
{
    if (inputField) {
        return self.inputFieldValues[inputField];
    } else {
        return nil;
    }
}

- (BOOL)_isInputFieldValid:(LIFEInputField *)inputField
{
    if (inputField.required) {
        NSString *inputFieldValue = [self _currentValueForInputField:inputField];
        
        if (inputFieldValue == nil || inputFieldValue.length == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (nullable NSArray<LIFEInputField *> *)_incompleteInputFields
{
    NSMutableArray<LIFEInputField *> *incompleteInputFields = [NSMutableArray array];
    
    for (LIFEInputField *inputField in _inputFields) {
        if (![self _isInputFieldValid:inputField]) {
            [incompleteInputFields addObject:inputField];
        }
    }
    
    return [NSArray arrayWithArray:incompleteInputFields];
}

- (void)_doneButtonTapped:(id)sender
{
    [self _submitReport];
}

- (void)_submitReport
{
    let incompleteInputFields = [self _incompleteInputFields];

    if (incompleteInputFields.count > 0) {
        [self _highlightIncompleteInputFieldsAndShowErrorAlert:incompleteInputFields];
        return;
    }
    
    // Hide keyboard
    [self.view endEditing:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:LIFENotificationLoggerSendButtonTapped object:nil];

    self.doneButton.enabled = NO;
    NSString *whatHappened = self._summaryInputFieldValue;
    LIFEReportBuilder *reportBuilder = self.reportBuilder;
    reportBuilder.whatHappened = whatHappened;
    reportBuilder.reproSteps = self.reproSteps;
    reportBuilder.expectedResults = self.expectedResults;
    reportBuilder.actualResults = self.actualResults;

    // Get the email address, using either the email address field (if it's enabled),
    // or the programmatically configured email address
    LIFEInputField *userEmailInputField = [self _userEmailInputField];

    if (userEmailInputField) {
        NSString *userInputtedEmailOrEmptyString = self._userEmailInputFieldValue;

        if (userInputtedEmailOrEmptyString.length > 0) {
            reportBuilder.userEmail = userInputtedEmailOrEmptyString;
            [LIFEUserDefaults sharedDefaults].lastSubmittedUserEmailFieldValue = userInputtedEmailOrEmptyString;
        }
    } else {
        reportBuilder.userEmail = [Buglife sharedBuglife].userEmail;
    }

    // Set custom attribute values w/ new values from custom fields
    {
        NSMutableDictionary<NSString *, LIFEAttribute *> *attributes = reportBuilder.attributes.mutableCopy;

        for (LIFEInputField *inputField in self.inputFieldValues.allKeys) {
            if (inputField.isSystemAttribute) {
                // Skip system attributes since they aren't custom attributes, and will
                // get added to the report payload separately
                continue;
            }

            let attributeName = inputField.attributeName;
            let inputFieldValue = self.inputFieldValues[inputField];

            if (inputFieldValue) {
                let attribute = [[LIFEAttribute alloc] initWithValueType:LIFEAttributeValueTypeString value:inputFieldValue flags:LIFEAttributeFlagCustom];
                attributes[attributeName] = attribute;
            }
        }

        reportBuilder.attributes = attributes;
    }

    void (^completionBlock)(BOOL) = nil;
    BOOL blockingSubmissionEnabled = [self.delegate reportViewControllerShouldSubmitSynchronously:self];

    if (blockingSubmissionEnabled) {
        __weak typeof(self) weakSelf = self;
        UIView *loadingView = [self _showBlockingLoadingView];

        completionBlock = ^(BOOL submitted) {
            if (!submitted) {
                [loadingView removeFromSuperview];

                __strong LIFEReportTableViewController *strongSelf = weakSelf;

                if (strongSelf) {
                    strongSelf.doneButton.enabled = YES;
                    [self _showSubmissionErrorAlert];
                }
            }
        };
    }

    [self.delegate reportViewController:self shouldCompleteReportBuilder:reportBuilder completion:completionBlock];
}

- (UIBarButtonItem *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:LIFELocalizedString(LIFEStringKey_Done) style:UIBarButtonItemStyleDone target:self action:@selector(_doneButtonTapped:)];
    }
    
    return _doneButton;
}

- (nonnull UIView *)_showBlockingLoadingView
{
    UIView *loadingViewParent = self.navigationController.view;
    CGRect loadingViewRect = loadingViewParent.frame;
    UIView *loadingView = [[UIView alloc] initWithFrame:loadingViewRect];
    loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingView addSubview:activityIndicatorView];
    activityIndicatorView.center = loadingView.center;
    [loadingViewParent addSubview:loadingView];
    [activityIndicatorView startAnimating];
    return loadingView;
}

- (void)_showSubmissionErrorAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LIFELocalizedString(LIFEStringKey_ReportSubmissionErrorAlertTitle) message:LIFELocalizedString(LIFEStringKey_ReportSubmissionErrorAlertMessage) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_OK) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Error surfacing

- (void)_highlightIncompleteInputFieldsAndShowErrorAlert:(NSArray<LIFEInputField *> *)incompleteInputFields
{
    NSArray<UITableViewCell *> *cells = [incompleteInputFields life_map:^id(LIFEInputField *inputField) {
        let indexPath = [self _indexPathForInputField:inputField];
        return [self.tableView cellForRowAtIndexPath:indexPath];
    }];
    
    NSArray<UIColor *> *originalBackgroundColors = [cells life_map:^id(UITableViewCell *cell) {
        return cell.backgroundColor;
    }];
    
    NSArray<UIColor *> *errorBackgroundColors = [cells life_map:^id(UITableViewCell *obj) {
        return [[UIColor redColor] colorWithAlphaComponent:0.25];
    }];
    
    __weak typeof(self) weakSelf = self;
    
    [self _setBackgroundColors:errorBackgroundColors forInputFields:incompleteInputFields animated:NO];
    
    [self _presentErrorForIncompleteInputFields:incompleteInputFields dismissHandler:^{
        __strong LIFEReportTableViewController *strongSelf = weakSelf;
        [strongSelf _setBackgroundColors:originalBackgroundColors forInputFields:incompleteInputFields animated:YES];
    }];
}

- (void)_presentErrorForIncompleteInputFields:(NSArray<LIFEInputField *> *)incompleteInputFields dismissHandler:(void (^ __nullable)(void))dismissHandler
{
    NSString *message;
    
    if (incompleteInputFields.count == 1) {
        let incompleteField = incompleteInputFields.firstObject;
        message = [NSString stringWithFormat:@"\"%@\" is a required field.", incompleteField.title];
    } else {
        message = [NSString stringWithFormat:@"%lu required fields are incomplete.", (unsigned long)incompleteInputFields.count];
    }
    
    let alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:message preferredStyle:UIAlertControllerStyleAlert];
    let action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        dismissHandler();
    }];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)_setBackgroundColors:(NSArray<UIColor *> *)backgroundColors forInputFields:(NSArray<LIFEInputField *> *)inputFields animated:(BOOL)animated
{
    NSArray<UITableViewCell *> *cells = [inputFields life_map:^id(LIFEInputField *inputField) {
        let indexPath = [self _indexPathForInputField:inputField];
        return [self.tableView cellForRowAtIndexPath:indexPath];
    }];
    
    void (^changeBlock)(void) = ^{
        for (int i = 0; i < backgroundColors.count; i++) {
            UITableViewCell *cell = cells[i];
            cell.backgroundColor = backgroundColors[i];
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:2.0f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:changeBlock completion:nil];
    } else {
        changeBlock();
    }
}

#pragma mark - Cancel button

- (void)_cancelButtonTapped:(id)sender
{
    BOOL isDirty = (self.userFacingAttachments.count > 0) || self.isDirty;
    
    if (isDirty) {
        UIAlertControllerStyle style = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? UIAlertControllerStyleActionSheet : UIAlertControllerStyleAlert;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:LIFELocalizedString(LIFEStringKey_DiscardReportAlertTitle) message:LIFELocalizedString(LIFEStringKey_DiscardReportAlertMessage) preferredStyle:style];
        UIAlertAction *discardAction = [UIAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_DiscardReportAlertConfirm) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self _confirmCancel];
        }];
        [alert addAction:discardAction];
        
        UIAlertAction *nevermindAction = [UIAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_DiscardReportAlertCancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // do nothing
        }];
        [alert addAction:nevermindAction];
        
        [self presentViewController:alert animated:YES completion:NULL];
    } else {
        [self _confirmCancel];
    }
}

- (void)_confirmCancel
{
    [self resignFirstResponder];
    [self.delegate reportViewControllerDidCancel:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = 1; // Attachments
    
    return sectionCount + _inputFields.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;

    if (section == kAttachmentSectionNumber) {
        rowCount += self.userFacingAttachments.count;

        if ([self _indexPathForAddAttachmentCell]) {
            rowCount += 1;
        }
        
        return rowCount;
    } else {
        return 1;
    }
    
    NSParameterAssert(NO);
    return 0;
}

- (BOOL)_isInputFieldAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section > 0;
}

- (NSIndexPath *)_indexPathForInputField:(LIFEInputField *)inputField
{
    NSUInteger section = [_inputFields indexOfObject:inputField];
    section += 1;
    return [NSIndexPath indexPathForRow:0 inSection:section];
}

- (LIFEInputField *)_inputFieldForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _inputFields[indexPath.section - 1];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return LIFELocalizedString(LIFEStringKey_Attachments);
    } else {
        LIFEInputField *inputField = _inputFields[section - 1];
        return inputField.title;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kAttachmentSectionNumber) {
        if ([indexPath isEqual:[self _indexPathForAddAttachmentCell]]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = LIFELocalizedString(LIFEStringKey_AttachPhoto);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        } else {
            LIFEAttachmentCell *cell = [tableView dequeueReusableCellWithIdentifier:[LIFEAttachmentCell defaultIdentifier] forIndexPath:indexPath];
            id<LIFEUserFacingAttachment> userFacingAttachment = self.userFacingAttachments[indexPath.row];
            
            if ([userFacingAttachment isKindOfClass:[LIFEAnnotatedImage class]]) {
                LIFEAnnotatedImage *annotatedImage = (LIFEAnnotatedImage *)userFacingAttachment;
                [self _configureCell:cell withAnnotatedImage:annotatedImage];
            } else if ([userFacingAttachment isKindOfClass:[LIFEVideoAttachment class]]) {
                LIFEVideoAttachment *videoAttachment = (LIFEVideoAttachment *)userFacingAttachment;
                [self _configureCell:cell withVideoAttachment:videoAttachment];
            }
            
            return cell;
        }
    } else {
        LIFEInputField *inputField = [self _inputFieldForRowAtIndexPath:indexPath];
        NSString *currentInputFieldValue = [self _currentValueForInputField:inputField];
        
        if ([inputField isKindOfClass:[LIFEPickerInputField class]]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPickerCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = currentInputFieldValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        } else if ([inputField isKindOfClass:[LIFETextInputField class]]) {
            let textInputField = (LIFETextInputField *)inputField;
            
            if (textInputField.isMultiline) {
                LIFEWhatHappenedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[LIFEWhatHappenedTableViewCell defaultIdentifier] forIndexPath:indexPath];
                cell.textView.placeholderText = textInputField.placeholder;
                cell.textView.accessibilityLabel = textInputField.placeholder;
                cell.textView.text = currentInputFieldValue;
                cell.textView.inputField = inputField;
                cell.textView.lifeDelegate = self;
                
                return cell;
            } else {
                LIFETextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:[LIFETextFieldCell defaultIdentifier] forIndexPath:indexPath];
                cell.delegate = self;
                cell.textField.placeholder = textInputField.placeholder;
                cell.textField.returnKeyType = UIReturnKeyNext;
                cell.inputField = inputField;
                
                cell.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                cell.textField.keyboardType = UIKeyboardTypeDefault;
                cell.textField.text = currentInputFieldValue;
                
                if (inputField.isUserEmailField) {
                    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                }
                
                return cell;
            }
        }
    }
    
    NSParameterAssert(NO);
    return nil;
}

- (void)_configureCell:(LIFEAttachmentCell *)cell withAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    [cell setThumbnailImage:nil];
    [cell setTitle:annotatedImage.filename];
    
    CGSize targetSize = [LIFEAttachmentCell targetImageSize];
    targetSize = LIFECGSizeAspectFill(annotatedImage.sourceImage.size, targetSize);
    
    __weak LIFEAnnotatedImage *weakAnnotatedImage = annotatedImage;
    
    [self.imageProcessor getFlattenedScaledImageForAnnotatedImage:annotatedImage targetSize:targetSize toQueue:dispatch_get_main_queue() completion:^(LIFEImageIdentifier *identifier, UIImage *result) {
        __strong LIFEAnnotatedImage *strongAnnotatedImage = weakAnnotatedImage;
        if (strongAnnotatedImage) {
            if ([identifier isEqual:strongAnnotatedImage.identifier]) {
                [UIView animateWithDuration:0.15 animations:^{
                    [cell setThumbnailImage:result];
                }];
            }
        }
    }];
}

- (void)_configureCell:(LIFEAttachmentCell *)cell withVideoAttachment:(LIFEVideoAttachment *)videoAttachment
{
    [cell setThumbnailImage:videoAttachment.getThumbnail];
    [cell setTitle:videoAttachment.filename];
    [cell setActivityIndicatorViewIsAnimating:videoAttachment.isProcessing];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _isInputFieldAtIndexPath:indexPath]) {
        LIFEInputField *inputField = [self _inputFieldForRowAtIndexPath:indexPath];
        
        if ([inputField isKindOfClass:[LIFETextInputField class]]) {
            LIFETextInputField *textInputField = (LIFETextInputField *)inputField;
            
            if (textInputField.isMultiline) {
                NSNumber *cachedHeight = self.inputFieldRowHeightCache[inputField];
                
                if (cachedHeight != nil) {
                    return cachedHeight.floatValue;
                } else {
                    LIFEInputFieldValue *value = self.inputFieldValues[inputField];
                    CGFloat boundsWidth = CGRectGetWidth(tableView.bounds);
                    return [LIFEWhatHappenedTableViewCell heightWithText:value boundsWidth:boundsWidth];
                }
            }
        }
    }
    
    return kDefaultRowHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kAttachmentSectionNumber && ![indexPath isEqual:[self _indexPathForAddAttachmentCell]]) {
        return YES;
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dirty = YES;
    
    // First, check whether the add attachments button was visible prior to deleting
    BOOL addAttachmentsButtonPreviouslyEnabled = [self addAttachmentsButtonEnabled];
    
    // Delete the image object
    [self.reportBuilder deleteAnnotatedImageAtIndex:indexPath.row];
    
    // Check if the add attachments button should be enabled afterwards
    BOOL insertAddAttachmentsButton = (addAttachmentsButtonPreviouslyEnabled != [self addAttachmentsButtonEnabled]);
    
    [tableView beginUpdates];
    
    // Delete the row for the image
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // If necessary, insert the row for Add Attachments
    if (insertAddAttachmentsButton) {
        NSArray *indexPaths = @[[self _indexPathForAddAttachmentCell]];
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [tableView endUpdates];
}

#pragma mark - Row index paths

- (NSIndexPath *)_indexPathForAddAttachmentCell
{
    if ([self addAttachmentsButtonEnabled]) {
        NSInteger row = self.userFacingAttachments.count;
        return [NSIndexPath indexPathForRow:row inSection:kAttachmentSectionNumber];
    } else {
        return nil;
    }
}

#pragma mark - Row selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kAttachmentSectionNumber) {
        if ([indexPath isEqual:[self _indexPathForAddAttachmentCell]]) {
            [self _presentAddAttachmentControllerAnimated:YES];
        } else {
            [self _life_hideKeyboard];
            self.indexOfCurrentEditingAnnotatedImage = indexPath.row;
            
            id<LIFEUserFacingAttachment> userFacingAttachment = self.userFacingAttachments[self.indexOfCurrentEditingAnnotatedImage];
            
            if ([userFacingAttachment isKindOfClass:[LIFEAnnotatedImage class]]) {
                LIFEAnnotatedImage *annotatedImage = (LIFEAnnotatedImage *)userFacingAttachment;
                
                if (kUseNewImageEditor) {
                    let vc = [[LIFEImageEditorViewController alloc] initWithAnnotatedImage:annotatedImage];
                    vc.delegate = self;
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    let vc = [[LIFEScreenshotAnnotatorViewController alloc] initWithAnnotatedImage:annotatedImage];
                    vc.delegate = self;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            } else if ([userFacingAttachment isKindOfClass:[LIFEVideoAttachment class]]) {
                LIFEVideoAttachment *videoAttachment = (LIFEVideoAttachment *)userFacingAttachment;
                [self _presentVideoPlayerWithAttachment:videoAttachment];
            } else {
                // Just deselect the row
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                });
            }
        }
    } else {
        LIFEInputField *inputField = [self _inputFieldForRowAtIndexPath:indexPath];
        
        if ([inputField isKindOfClass:[LIFEPickerInputField class]]) {
            [self _life_hideKeyboard];
            let pickerInputField = (LIFEPickerInputField *)inputField;
            let pickerViewController = [[LIFEPickerViewController alloc] initWithPickerInputField:pickerInputField];
            pickerViewController.pickerDelegate = self;
            [self.navigationController pushViewController:pickerViewController animated:YES];
        }
    }
}

- (void)_presentVideoPlayerWithAttachment:(LIFEVideoAttachment *)videoAttachment
{
    [LIFEAVPlayerViewController presentFromViewController:self playerWithURL:videoAttachment.url animated:YES];
}

// This is namespaced because I'm super-paranoid about conflicting w/ private Apple APIs
- (void)_life_hideKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - Accessors

- (NSArray<LIFEUserFacingAttachment> *)userFacingAttachments
{
    return self.reportBuilder.userFacingAttachments;
}

#pragma mark - LIFEScreenshotAnnotatorViewControllerDelegate

- (void)screenshotAnnotatorViewController:(LIFEScreenshotAnnotatorViewController *)screenshotAnnotatorViewController willCompleteWithAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    [self _willCompleteImageEditorWithAnnotatedImage:annotatedImage];
}

#pragma mark - LIFEImageEditorViewControllerDelegate

- (void)imageEditorViewController:(nonnull LIFEImageEditorViewController *)controller willCompleteWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage
{
    [self _willCompleteImageEditorWithAnnotatedImage:annotatedImage];
}

- (void)_willCompleteImageEditorWithAnnotatedImage:(nonnull LIFEAnnotatedImage *)annotatedImage
{
    if (self.indexOfCurrentEditingAnnotatedImage == kNoCurrentEditingAnnotatedImage) {
        LIFELogIntError(@"Completed annotating image, but index is not found");
        NSParameterAssert(NO);
        return;
    } else if (self.indexOfCurrentEditingAnnotatedImage > self.userFacingAttachments.count) {
        LIFELogIntError(@"Completed annotating image, but index is greater than # of annotated images");
        NSParameterAssert(NO);
        return;
    }
    
    // Invalidate the image cache
    [self.imageProcessor clearImageCache];
    
    // Replace the stored annotated image
    [self.reportBuilder replaceAnnotatedImageAtIndex:self.indexOfCurrentEditingAnnotatedImage withAnnotatedImage:annotatedImage];
    
    // Reload that row so that the thumbnail is updated
    NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:self.indexOfCurrentEditingAnnotatedImage inSection:kAttachmentSectionNumber];
    [self.tableView reloadRowsAtIndexPaths:@[indexPathToReload] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // Reset
    self.indexOfCurrentEditingAnnotatedImage = kNoCurrentEditingAnnotatedImage;
}

#pragma mark - LIFEWhatHappenedTextViewDelegate

- (void)whatHappenedTextViewDidChange:(LIFEWhatHappenedTextView *)textView
{
    self.dirty = YES;
    
    LIFEInputField *inputField = textView.inputField;
    NSParameterAssert(inputField);
    NSString *value = textView.text;
    [self _setValue:value forInputField:inputField];
    //[self.whatHappenedRowHeight setHeightWithText:self.whatHappenedText inTableView:self.tableView];
    
    LIFEWhatHappenedTableViewCell *cell = textView.tableViewCell;
    
    if (cell != nil) {
        CGFloat boundsWidth = CGRectGetWidth(self.tableView.bounds);
        CGFloat newHeight = [LIFEWhatHappenedTableViewCell heightWithText:value boundsWidth:boundsWidth];
        BOOL updateRowHeight = NO;
        NSNumber *oldHeightNum = self.inputFieldRowHeightCache[inputField];
        
        if (oldHeightNum != nil) {
            CGFloat oldHeight = oldHeightNum.floatValue;
            
            if (ABS(oldHeight - newHeight) > 2.0f) {
                updateRowHeight = YES;
            }
        } else {
            updateRowHeight = YES;
        }
        
        if (updateRowHeight) {
            self.inputFieldRowHeightCache[inputField] = @(newHeight);
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }
    }
}

#pragma mark - LIFEStepsToReproTableViewControllerDelegate

- (void)stepsToReproTableViewController:(LIFEStepsToReproTableViewController *)stepsToReproTableViewController didUpdateReproSteps:(NSArray<LIFEReproStep *> *)reproSteps
{
    self.reproSteps = reproSteps;
}

#pragma mark - LIFETextInputViewControllerDelegate

- (void)textInputViewControllerTextDidChange:(LIFETextInputViewController *)textInputViewController
{
    if (textInputViewController == self.expectedResultsViewController) {
        self.expectedResults = textInputViewController.text;
    } else if (textInputViewController == self.actualResultsViewController) {
        self.actualResults = textInputViewController.text;
    } else {
        NSParameterAssert(NO);
    }
}

#pragma mark - LIFETextFieldCellDelegate

- (void)textFieldCellDidReturn:(LIFETextFieldCell *)textFieldCell
{
    [textFieldCell resignFirstResponder];
}

- (void)textFieldCellDidChange:(LIFETextFieldCell *)textFieldCell
{
    LIFEInputField *inputField = textFieldCell.inputField;
    NSParameterAssert(inputField);
    NSString *value = textFieldCell.textField.text;
    [self _setValue:value forInputField:inputField];
}

- (void)_setValue:(nullable NSString *)value forInputField:(nonnull LIFEInputField *)inputField
{
    if (value == nil) {
        value = @""; // Make sure we don't accidentally try to set a nil value
    }
    
    _inputFieldValues[inputField] = value;
}

#pragma mark - LIFEPickerViewControllerDelegate

- (void)pickerViewController:(nonnull LIFEPickerViewController *)pickerViewController didSelectOptionAtIndex:(NSUInteger)index
{
    self.dirty = YES;
    
    let pickerInputField = pickerViewController.pickerInputField;
    let optionValue = pickerInputField.optionValuesArray[index];
    [self _setValue:optionValue forInputField:pickerInputField];
    
    [self.navigationController popToViewController:self animated:YES];
    
    // Refresh the table view cell for that picker field
    let pickerSection = [_inputFields indexOfObject:pickerInputField] + 1;
    let pickerIndexPath = [NSIndexPath indexPathForRow:0 inSection:pickerSection];
    [self.tableView reloadRowsAtIndexPaths:@[pickerIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSUInteger)selectedIndexForPickerViewController:(nonnull LIFEPickerViewController *)pickerViewController
{
    let pickerInputField = pickerViewController.pickerInputField;
    let currentInputFieldValue = [self _currentValueForInputField:pickerInputField];
    
    if (currentInputFieldValue.length > 0) {
        let optionValues = pickerInputField.optionValuesArray;
        return [optionValues indexOfObject:currentInputFieldValue];
    }
    
    return NSNotFound;
}

@end

#import <AssetsLibrary/AssetsLibrary.h>

@implementation LIFEReportTableViewController (AddAttachments)

// This is actually an Apple-defined string, but I don't know if they have a key for it (it's a string used as a key in an app's info.plist)
static NSString * const LIFENSPhotoLibraryUsageDescriptionKey = @"NSPhotoLibraryUsageDescription";
static const NSUInteger kMaxImageAttachmentCount = 3;

- (void)_presentAddAttachmentControllerAnimated:(BOOL)animated
{
    if (![self addAttachmentsButtonEnabled]) {
        LIFELogExtError(@"Buglife error: Unable to add attachments. This may be because your app does not have access to the user's photo gallery, or because the current bug report has already exceeded the maximum total attachment size.");
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self.imagePickerController tryPresentImagePickerControllerAnimated:animated didPresentHandler:^(BOOL didPresent) {
        __strong LIFEReportTableViewController *strongSelf = weakSelf;
        if (strongSelf) {
            if (!didPresent) {
                [strongSelf.tableView deselectRowAtIndexPath:strongSelf.tableView.indexPathForSelectedRow animated:animated];
            }
        }
    }];
}

- (void)_addAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    [self.reportBuilder addAnnotatedImage:annotatedImage];
}

- (BOOL)addAttachmentsButtonEnabled
{
    if (!_allowsAdditionalAttachments) {
        return NO;
    }
    
    if (self.reportBuilder.userFacingAttachments.count >= kMaxImageAttachmentCount) {
        return NO;
    }

    return [self.imagePickerController isImagePickerAvailable];
}

- (void)_logWarningIfPhotoLibraryUsageDescriptionRequiredAndMissing
{
    if ([self.imagePickerController isPhotoLibraryUsageDescriptionRequiredAndMissing]) {
        LIFELogExtWarn(@"Buglife warning: The photo picker cannot be accessed because your app's info.plist is missing the %@ key.", LIFENSPhotoLibraryUsageDescriptionKey);
    }
}

#pragma mark - LIFEImagePickerControllerDelegate

- (UIViewController *)presentingViewControllerForImagePickerController:(LIFEImagePickerController *)imagePickerController
{
    return self;
}

- (void)imagePickerController:(nonnull LIFEImagePickerController *)picker didFinishPickingImage:(nonnull UIImage *)image withFilename:(nonnull NSString *)filename uniformTypeIdentifier:(nonnull NSString *)uniformTypeIdentifier
{
    LIFEImageFormat imageFormat = LIFEImageFormatFromUniformTypeIdentifierAndFilename(uniformTypeIdentifier, filename);
    LIFEAnnotatedImage *annotatedImage = [[LIFEAnnotatedImage alloc] initWithSourceImage:image filename:filename format:imageFormat];
    [self _addAnnotatedImage:annotatedImage];
}

- (void)imagePickerController:(LIFEImagePickerController *)picker didFinishPickingVideoWithMediaURL:(NSURL *)mediaURL withFilename:(NSString *)filename uniformTypeIdentifier:(NSString *)uniformTypeIdentifier
{
    LIFEVideoAttachment *video = [[LIFEVideoAttachment alloc] initWithFileURL:mediaURL uniformTypeIdentifier:uniformTypeIdentifier filename:filename isProcessing:YES];
    [self.reportBuilder addVideoAttachment:video];
}

- (void)imagePickerContrllerDidPickUnsupportedContentType:(LIFEImagePickerController *)picker
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LIFELocalizedString(LIFEStringKey_GenericAlertTitle) message:@"The attachment type you selected is not currently supported." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:LIFELocalizedString(LIFEStringKey_OK) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
