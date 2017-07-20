//
//  SSJWishChargeCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJWishChargeCell : SSJBaseTableViewCell
+ (SSJWishChargeCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

typedef void(^SSJWishChargeEdidBlock)(SSJWishChargeCell *cell);

typedef void(^SSJWishChargeDelegateBlock)(SSJWishChargeCell *cell);

@property (nonatomic, copy) SSJWishChargeEdidBlock wishChargeEdidBlock;

@property (nonatomic, copy) SSJWishChargeDelegateBlock wishChargeDelegateBlock;
@end
