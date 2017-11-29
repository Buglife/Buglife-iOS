//
//  LIFETextInputViewController.m
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

#import "LIFETextInputViewController.h"
#import "LIFEWhatHappenedTextView.h"

@interface LIFETextInputViewController () <LIFEWhatHappenedTextViewDelegate>

@property (nonatomic) LIFEWhatHappenedTableViewCell *whatHappenedCell;
@property (nonatomic) LIFEWhatHappenedHeightCache *heightCache;

@end

@implementation LIFETextInputViewController

@dynamic text;
@dynamic placeholder;

#pragma mark - Initialization

- (instancetype)initWithText:(NSString *)text
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _whatHappenedCell = [[LIFEWhatHappenedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[LIFEWhatHappenedTableViewCell defaultIdentifier]];
        _whatHappenedCell.textView.lifeDelegate = self;
        _whatHappenedCell.textView.text = text;
        _heightCache = [[LIFEWhatHappenedHeightCache alloc] init];
    }
    return self;
}

#pragma mark - UIResponder

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.whatHappenedCell.textView becomeFirstResponder];
}

#pragma mark - Accessors

- (NSString *)text
{
    return _whatHappenedCell.textView.text;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    self.whatHappenedCell.textView.placeholderText = placeholder;
}

- (NSString *)placeholder
{
    return self.whatHappenedCell.textView.placeholderText;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _whatHappenedCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = self.whatHappenedCell.textView.text;
    CGFloat boundsWidth = CGRectGetWidth(tableView.bounds);
    return [LIFEWhatHappenedTableViewCell heightWithText:text boundsWidth:boundsWidth];
}

#pragma mark - LIFEWhatHappenedTextViewDelegate

- (void)whatHappenedTextViewDidChange:(LIFEWhatHappenedTextView *)textView
{
    [self.heightCache setHeightWithText:textView.text inTableView:self.tableView];
    [self.delegate textInputViewControllerTextDidChange:self];
}

@end
