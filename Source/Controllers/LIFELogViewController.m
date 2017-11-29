//
//  LIFELogViewController.m
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

#import "LIFELogViewController.h"
#import "LIFELogFacility.h"

@interface LIFELogViewController ()

@property (nonatomic) UITextView *logView;
@property (nonatomic) LIFELogFacility *logFacility;
@property (nonatomic) NSUInteger counter;

@end

@implementation LIFELogViewController

- (void)loadView
{
    self.logView = [[UITextView alloc] init];
    self.view = self.logView;
    _counter = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _refresh];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Append" style:UIBarButtonItemStylePlain target:self action:@selector(_appendButtonTapped:)];
}

- (void)_appendButtonTapped:(id)sender
{
    for (int i = 0; i < 50; i++) {
        _counter += 1;
    }
    
    [self _refresh];
}

- (void)_refresh
{
    __weak typeof(self) weakSelf = self;
    _logFacility = [[LIFELogFacility alloc] init];
    [_logFacility fetchFormattedLogsToQueue:dispatch_get_main_queue() completion:^(NSString *logs) {
        weakSelf.logView.text = logs;
    }];
}

@end
