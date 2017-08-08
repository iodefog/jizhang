//
//  SSJWishChargeCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJWishChargeCell : SSJBaseTableViewCell
+ (SSJWishChargeCell *)cellWithTableView:(UITableView *)tableView;

- (void)cellLayoutWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

/**是否允许编辑*/
@property (nonatomic, assign,getter=isAlowEdit) BOOL alowEdit;

typedef void(^SSJWishChargeEdidBlock)(SSJWishChargeCell *cell);

typedef void(^SSJWishChargeDeleteBlock)(SSJWishChargeCell *cell);

@property (nonatomic, copy) SSJWishChargeEdidBlock wishChargeEdidBlock;

@property (nonatomic, copy) SSJWishChargeDeleteBlock wishChargeDeleteBlock;
@end
