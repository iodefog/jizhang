//
//  SSJCalendarTableViewCell.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJBillingChargeCellItem.h"

@interface SSJCalendarTableViewCell : SSJBaseTableViewCell

@property(nonatomic, strong) SSJBillingChargeCellItem *item;

@property(nonatomic) BOOL isLastRow;

@property(nonatomic) BOOL isFirstRow;

@end
