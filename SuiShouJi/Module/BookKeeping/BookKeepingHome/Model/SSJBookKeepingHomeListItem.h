//
//  SSJBookKeepingHomeListItem.h
//  SuiShouJi
//
//  Created by ricky on 16/10/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"
#import "SSJBillingChargeCellItem.h"

@interface SSJBookKeepingHomeListItem : SSJBaseItem

@property(nonatomic) double balance;

@property(nonatomic, strong) NSString *date;

@property(nonatomic, strong) NSMutableArray <SSJBillingChargeCellItem *> *chargeItems;

@property(nonatomic) NSInteger totalCount;

@end
