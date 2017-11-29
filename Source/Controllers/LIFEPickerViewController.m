//
//  LIFEPickerViewController.m
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

#import "LIFEPickerViewController.h"
#import "LIFEPickerInputField+Protected.h"
#import "LIFEMacros.h"

static let kCellIdentifier = @"com.buglife.PickerCell";

@interface LIFEPickerViewController ()

@property (nonatomic, nonnull) LIFEPickerInputField *pickerInputField;

@end

@implementation LIFEPickerViewController

- (instancetype)initWithPickerInputField:(LIFEPickerInputField *)pickerInputField
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _pickerInputField = pickerInputField;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _pickerInputField.title;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pickerInputField.optionTitlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    let cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    let optionTitle = self.pickerInputField.optionTitlesArray[indexPath.row];
    cell.textLabel.text = optionTitle;
    
    NSUInteger selectedIndex = [self.pickerDelegate selectedIndexForPickerViewController:self];
    
    if (selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    let index = (NSUInteger)indexPath.row;
    [self.pickerDelegate pickerViewController:self didSelectOptionAtIndex:index];
}

@end
