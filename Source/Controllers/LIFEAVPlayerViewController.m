//
//  LIFEAVPlayerViewController.m
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

#import "LIFEAVPlayerViewController.h"
#import "LIFEMacros.h"
#import "LIFEDependencyLoader.h"

@protocol LIFEAVPlayer <NSObject>
- (void)play;
- (instancetype)initWithURL:(NSURL *)url;
@end

@protocol LIFEAVPlayerViewController <NSObject>
@property (strong, nullable) NSObject<LIFEAVPlayer> *player;
@end

@implementation LIFEAVPlayerViewController

#pragma mark - Public methods

+ (void)presentFromViewController:(UIViewController *)presentingViewController playerWithURL:(NSURL *)url animated:(BOOL)animated
{
    LIFELoadAVKit();
    LIFELoadAVFoundation();
    
    Class avPlayerClass = NSClassFromString(@"AVPlayer");
    Class avPlayerViewControllerClass = NSClassFromString(@"AVPlayerViewController");
    
    if (avPlayerClass && avPlayerViewControllerClass) {
        NSObject<LIFEAVPlayer> *player = [[avPlayerClass alloc] initWithURL:url];
        UIViewController<LIFEAVPlayerViewController> *playerViewController = [[avPlayerViewControllerClass alloc] init];
        playerViewController.player = player;
        [presentingViewController presentViewController:playerViewController animated:YES completion:^{
            [player play];
        }];
    } else {
        LIFELogExtWarn(@"Buglife warning: AVKit.framework and/or AVFoundation.framework isn't linked");
    }
}

@end
