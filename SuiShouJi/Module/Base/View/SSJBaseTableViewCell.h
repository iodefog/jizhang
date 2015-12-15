//
//  SSJBaseTableViewCell.h
//  MoneyMore
//
//  Created by old lang on 15-3-23.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBaseItem.h"

@interface SSJBaseTableViewCell : UITableViewCell

@property (nonatomic, strong) SSJBaseItem *cellItem;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object;

@end
