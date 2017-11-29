//
//  UITableView+LIFEAdditions.h
//  Pods
//
//  Created by David Schukin on 10/26/15.
//
//

#import <UIKit/UIKit.h>

@interface LIFEUITableViewCell : NSObject

+ (UITableView *)tableViewForCell:(UITableViewCell *)cell;
+ (NSString *)cellIdentifierForCell:(UITableViewCell *)cell;

@end
