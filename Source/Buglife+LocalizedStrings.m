//
//  Buglife+LocalizedStrings.m
//  Buglife
//
//  Copyright (c) 2017 Buglife, Inc. All rights reserved.
//

#import "Buglife+LocalizedStrings.h"
#import "LIFELocalizedStringProvider.h"

@implementation Buglife (LocalizedStrings)

- (BOOL)showStringKeys
{
    return [LIFELocalizedStringProvider sharedInstance].debugModeEnabled;
}

- (void)setShowStringKeys:(BOOL)showStringKeys
{
    [LIFELocalizedStringProvider sharedInstance].debugModeEnabled = showStringKeys;
}

@end
