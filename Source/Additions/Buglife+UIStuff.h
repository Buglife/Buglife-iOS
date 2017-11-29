//
//  Buglife+UIStuff.h
//  Pods
//
//  Created by David Schukin on 2/3/16.
//
//

#import "Buglife+Protected.h"

@interface Buglife (UIStuff)

- (void)_presentAlertControllerForInvocation:(LIFEInvocationOptions)invocation withScreenshot:(UIImage *)screenshot;
- (void)_notifyBuglifeInvoked;

@end

void LIFELoadCategoryFor_BuglifeUIStuff(void);
