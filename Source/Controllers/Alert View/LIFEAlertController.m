//
//  LIFEAlertController.m
//  Buglife
//
//  Created by David Schukin on 12/30/17.
//

#import "LIFEAlertController.h"
#import "LIFEAlertAnimator.h"
#import "LIFEAlertView.h"
#import "LIFEAlertAction.h"

@interface LIFEAlertController () <LIFEAlertViewDelegate>

@property (nonnull, nonatomic) LIFEAlertView *alertView;
@property (nullable, nonatomic) NSLayoutConstraint *alertViewWidthConstraint;

@end

@implementation LIFEAlertController

+ (nonnull instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    return [[LIFEAlertController alloc] initWithTitle:title];
}

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title
{
    self = [super init];
    if (self) {
        _alertView = [[LIFEAlertView alloc] initWithTitle:title];
        _alertView.delegate = self;
    }
    return self;
}

- (void)setImage:(nullable UIImage *)image
{
    [_alertView setImage:image];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.alertView];
    self.alertView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.alertView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.alertView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
        ]];
    
    _alertViewWidthConstraint = [self.alertView.widthAnchor constraintEqualToConstant:270];
    _alertViewWidthConstraint.active = YES;
    
    [self setDarkOverlayHidden:NO];
}

- (void)prepareExpandToDismissTransition
{
    _alertViewWidthConstraint.constant = self.view.bounds.size.width * 2.0;
}

#pragma mark - Public methods

- (void)addAction:(nonnull LIFEAlertAction *)action
{
    [self.alertView addAction:action];
}

- (void)setDarkOverlayHidden:(BOOL)hidden
{
    if (hidden) {
        self.view.backgroundColor = [UIColor clearColor];
    } else {
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
}

#pragma mark - LIFEAlertViewDelegate

- (void)alertViewDidSelectAction:(nonnull LIFEAlertAction *)action
{
    if (action.style == UIAlertActionStyleCancel) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            action.handler(action);
        }];
    } else {
        action.handler(action);
    }
}

@end
