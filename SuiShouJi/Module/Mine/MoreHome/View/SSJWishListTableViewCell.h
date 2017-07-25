//
//  SSJWishListTableViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
@class SSJWishModel;
@interface SSJWishListTableViewCell : SSJBaseTableViewCell


+ (SSJWishListTableViewCell *)cellWithTableView:(UITableView *)tableView;

typedef void(^SSJWishSaveMoneyBlock)(SSJWishModel *item);
@property (nonatomic, copy) SSJWishSaveMoneyBlock wishSaveMoneyBlock;
@end
