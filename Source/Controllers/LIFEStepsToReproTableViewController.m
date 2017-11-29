//
//  LIFEStepsToReproTableViewController.m
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

#import "LIFEStepsToReproTableViewController.h"
#import "LIFEStepsToReproduceCell.h"
#import "LIFEReproStep.h"
#import "LIFEMacros.h"

static const NSUInteger kMaximumNumberOfReproSteps = 20;

@interface LIFEStepsToReproTableViewController () <LIFEStepsToReproduceCellDelegate>

@property (nonatomic, copy) NSArray<LIFEReproStep *> *reproSteps;

@end

@implementation LIFEStepsToReproTableViewController

#pragma mark - UIViewController

- (instancetype)initWithReproSteps:(NSArray<LIFEReproStep *> *)reproSteps
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        if (reproSteps.count == 0) {
            reproSteps = @[[[LIFEReproStep alloc] init]];
        }

        _reproSteps = reproSteps;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LIFELocalizedString(LIFEStringKey_StepsToReproduce);
    [self.tableView registerClass:[LIFEStepsToReproduceCell class] forCellReuseIdentifier:[LIFEStepsToReproduceCell defaultIdentifier]];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self _updateDelegate];
    [super viewWillDisappear:animated];
}

#pragma mark - UIResponder

- (BOOL)becomeFirstResponder
{
    NSInteger lastRow = [self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    UITableViewCell *lastCell = [self.tableView cellForRowAtIndexPath:lastIndexPath];
    return [lastCell becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reproSteps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LIFEStepsToReproduceCell *cell = [tableView dequeueReusableCellWithIdentifier:[LIFEStepsToReproduceCell defaultIdentifier] forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.reproStep = self.reproSteps[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setStepNumber:(indexPath.row + 1)];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LIFEReproStep *reproStep = self.reproSteps[indexPath.row];
    CGFloat width = CGRectGetWidth(tableView.bounds);
    CGFloat height = [LIFEStepsToReproduceCell heightWithReproStep:reproStep boundsWidth:width];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self _becomeFirstResponderForRowAtIndexPath:indexPath];
}

#pragma mark - LIFEStepsToReproduceCellDelegate

- (void)stepsToReproduceCellDidReturn:(LIFEStepsToReproduceCell *)stepsToReproduceCell
{
    if (self.reproSteps.count >= kMaximumNumberOfReproSteps) {
        [stepsToReproduceCell resignFirstResponder];
        return;
    }

    LIFEReproStep *nextStep = [[LIFEReproStep alloc] init];
    self.reproSteps = [self.reproSteps arrayByAddingObject:nextStep];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(self.reproSteps.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _becomeFirstResponderForRowAtIndexPath:newIndexPath];
    });
}

#pragma mark - Private methods

- (void)_becomeFirstResponderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell becomeFirstResponder];
}

- (void)_updateDelegate
{
    NSArray *reproSteps = [self.reproSteps filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LIFEReproStep *reproStep, NSDictionary *bindings) {
        return !reproStep.isEmpty;
    }]];
    
    NSParameterAssert(self.delegate);
    [self.delegate stepsToReproTableViewController:self didUpdateReproSteps:reproSteps];
}

@end
