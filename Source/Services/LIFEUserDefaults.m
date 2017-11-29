//
//  LIFEUserDefaults.m
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

#import "LIFEUserDefaults.h"

static NSString * const kSuiteName = @"com.buglife.buglife.userDefaults";
static NSString * const kFloatingButtonCenterPointX = @"LIFEFloatingButton.centerPoint.x";
static NSString * const kFloatingButtonCenterPointY = @"LIFEFloatingButton.centerPoint.y";
static NSString * const kLastSubmittedUserEmailFieldValue = @"LIFELastSubmittedUserEmailFieldValue";

@interface LIFEUserDefaults ()

@property (nonatomic) dispatch_queue_t workQueue;

@end

@implementation LIFEUserDefaults

+ (instancetype)sharedDefaults
{
    static LIFEUserDefaults *sSharedDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedDefaults = [[self alloc] init];
    });
    return sSharedDefaults;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _workQueue = dispatch_queue_create("com.buglife.buglife.LIFEUserDefaults.workQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - User email

@dynamic lastSubmittedUserEmailFieldValue;

- (void)setLastSubmittedUserEmailFieldValue:(NSString *)lastSubmittedUserEmailFieldValue
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [userDefaults setObject:lastSubmittedUserEmailFieldValue forKey:kLastSubmittedUserEmailFieldValue];
}

- (NSString *)lastSubmittedUserEmailFieldValue
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    return [userDefaults objectForKey:kLastSubmittedUserEmailFieldValue];
}

#pragma mark - Public methods

- (void)setLastFloatingButtonCenterPoint:(CGPoint)centerPoint
{
    dispatch_async(_workQueue, ^{
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
        [userDefaults setFloat:centerPoint.x forKey:kFloatingButtonCenterPointX];
        [userDefaults setFloat:centerPoint.y forKey:kFloatingButtonCenterPointY];
    });
}

// returns the default otherwise
- (void)getLastFloatingButtonCenterPointToQueue:(dispatch_queue_t)completionQueue completion:(void (^)(CGPoint centerPoint))completionHandler
{
    dispatch_async(_workQueue, ^{
        CGPoint centerPoint;
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
        
        centerPoint.x = [userDefaults floatForKey:kFloatingButtonCenterPointX];
        centerPoint.y = [userDefaults floatForKey:kFloatingButtonCenterPointY];
        
        // If it's zero, get the default by using 3/4 of the minimum width/height
        // of the screen
        if (CGPointEqualToPoint(centerPoint, CGPointZero)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIScreen *screen = [UIScreen mainScreen];
                NSParameterAssert(screen);
                CGSize screenSize = screen.bounds.size;
                
                CGFloat defaultPosition = MIN(screenSize.width, screenSize.height) * 0.75;
                CGPoint defaultPoint = CGPointMake(defaultPosition, defaultPosition);
                
                dispatch_async(completionQueue, ^{
                    completionHandler(defaultPoint);
                });
            });
        } else {
            dispatch_async(completionQueue, ^{
                completionHandler(centerPoint);
            });
        }
    });
}

@end
