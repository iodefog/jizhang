//
//  SSJFixedFinanceProductDetailCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJFixedFinanceProductDetailCell : SSJBaseTableViewCell

/**right*/
@property (nonatomic, strong) UILabel *amountL;

+ (SSJFixedFinanceProductDetailCell *)cellWithTableView:(UITableView *)tableView;
@end
