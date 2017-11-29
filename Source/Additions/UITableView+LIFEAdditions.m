//
//  UITableView+LIFEAdditions.m
//  Pods
//
//  Created by David Schukin on 10/26/15.
//
//

#import "UITableView+LIFEAdditions.h"

@implementation LIFEUITableViewCell

+ (UITableView *)tableViewForCell:(UITableViewCell *)cell
{
    id view = [cell superview];
    
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    
    UITableView *tableView = (UITableView *)view;
    return tableView;
}

+ (NSString *)cellIdentifierForCell:(UITableViewCell *)cell
{
    return NSStringFromClass([cell class]);
}

@end
