//
//  SSJSearchResultItem.h
//  SuiShouJi
//
//  Created by ricky on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
#import "SSJBillingChargeCellItem.h"

@interface SSJSearchResultItem : SSJBaseCellItem

typedef NS_ENUM(NSInteger, SSJChargeListOrder) {
    SSJChargeListOrderMoneyAscending,   //按金额升序
    SSJChargeListOrderMoneyDescending,  //按金额降序
    SSJChargeListOrderDateAscending,    //按日期升序
    SSJChargeListOrderDateDescending    //按日期降序
};

// 流水的日期
@property(nonatomic, strong) NSString *date;

// 当天流水的总额
@property(nonatomic) float balance;

// 当天的流水
@property(nonatomic, strong) NSMutableArray <SSJBillingChargeCellItem *> *chargeList;

@property(nonatomic) SSJChargeListOrder searchOrder;

@end
