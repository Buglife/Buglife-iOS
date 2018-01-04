//
//  LIFEClearNavigationController.m
//  Buglife
//
//  Created by David Schukin on 1/3/18.
//

#import "LIFEClearNavigationController.h"

@implementation LIFEClearNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)viewController
{
    self = [super initWithRootViewController:viewController];
    if (self) {
        [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [[UIImage alloc] init];
        self.navigationBar.translucent = YES;
        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
