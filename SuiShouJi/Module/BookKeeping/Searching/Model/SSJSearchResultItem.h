//
//  SSJSearchResultItem.h
//  SuiShouJi
//
//  Created by ricky on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"
#import "SSJBillingChargeCellItem.h"

@interface SSJSearchResultItem : SSJBaseItem

// 流水的日期
@property(nonatomic, strong) NSString *date;

// 当天流水的总额
@property(nonatomic) float balance;

// 当天的流水
@property(nonatomic, strong) NSMutableArray <SSJBillingChargeCellItem *> *chargeList;

@end
