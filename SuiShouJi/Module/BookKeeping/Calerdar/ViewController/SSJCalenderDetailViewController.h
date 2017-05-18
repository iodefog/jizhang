//
//  SSJCalenderDetailViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJDatePeriod.h"

@interface SSJCalenderDetailViewController :SSJNewBaseTableViewController

@property (nonatomic, strong) SSJBillingChargeCellItem *item;

@property (nonatomic, copy) void (^deleteHandler)();

@end
