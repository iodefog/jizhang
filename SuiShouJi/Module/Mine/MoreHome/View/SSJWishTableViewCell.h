//
//  SSJWishTableViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSJBaseTableViewCell.h"
@interface SSJWishTableViewCell : SSJBaseTableViewCell
+ (SSJWishTableViewCell *)cellWithTableView:(__kindof UITableView*)tableView;
- (void)setWishName:(NSString *)wishName readNum:(NSString *)readNum;
@end
