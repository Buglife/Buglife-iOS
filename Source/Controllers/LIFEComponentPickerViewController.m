//
//  LIFEComponentPickerViewController.m
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

#import "LIFEComponentPickerViewController.h"
#import "LIFEMacros.h"

static NSString * const kCellIdentifier = @"kCellIdentifier";

@interface LIFEComponentPickerViewController ()

@end

@implementation LIFEComponentPickerViewController

#pragma mark - Public methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LIFELocalizedString(LIFEStringKey_Component);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

#pragma mark - UITableViewDatasource / Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.components.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *component = self.components[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.textLabel.text = component;
    
    if ([self.selectedComponent isEqual:component]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *component = self.components[indexPath.row];
    [self.delegate componentPickerViewController:self didSelectComponent:component];
    
    // Manually add the checkmark, since we need to preserve the deselection animation
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Reload all the other rows
    NSMutableArray *otherIndexPaths = [[tableView indexPathsForVisibleRows] mutableCopy];
    [otherIndexPaths removeObject:indexPath];
    [tableView reloadRowsAtIndexPaths:otherIndexPaths withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Private methods

- (NSArray<NSString *> *)components
{
    return [self.delegate componentsForComponentPickerViewController:self];
}

- (NSString *)selectedComponent
{
    return [self.delegate selectedComponentForComponentPickerViewController:self];
}

@end
