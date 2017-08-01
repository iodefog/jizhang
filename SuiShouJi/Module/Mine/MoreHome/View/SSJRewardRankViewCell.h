//
//  SSJRewardRankViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/31.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJRewardRankViewCell : SSJBaseTableViewCell

+ (SSJRewardRankViewCell *)cellWithTableView:(UITableView *)tableView;

//第一行排序是否显示
- (void)isNotShowSelfRank:(BOOL)isNotShow;

@end
