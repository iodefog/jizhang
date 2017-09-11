//
//  SSJFixedFinanceDetailTableViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
@class SSJFixedFinanceProductItem;

@interface SSJFixedFinanceDetailTableViewCell : SSJBaseTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;

/**<#注释#>*/
@property (nonatomic, strong) SSJFixedFinanceProductItem *productItem;
@end
