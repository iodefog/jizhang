//
//  SSJCircleChargeCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJBillingChargeCellItem.h"

@interface SSJCircleChargeCell : SSJBaseTableViewCell

@property (nonatomic,strong) SSJBillingChargeCellItem *item;

typedef void (^openSpecialCircle)(SSJBillingChargeCellItem *item);

@property (nonatomic,copy)openSpecialCircle openSpecialCircle;

@end
