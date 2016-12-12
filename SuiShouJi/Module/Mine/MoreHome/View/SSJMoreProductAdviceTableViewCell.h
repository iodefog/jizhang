//
//  SSJMoreProductAdviceTableViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
@class SSJChatMessageItem;
@interface SSJMoreProductAdviceTableViewCell : UITableViewCell
+ (SSJMoreProductAdviceTableViewCell *)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) SSJChatMessageItem *message;
@end
