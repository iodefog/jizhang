//
//  SSJJiXiMethodTableViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJJiXiMethodTableViewCell : SSJBaseTableViewCell

@property (nonatomic, strong) UIImageView *additionalIcon;

@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *detailL;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
