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

@interface SSJCalenderDetailViewController :SSJNewBaseTableViewController<UIAlertViewDelegate>

@property (nonatomic,strong) SSJBillingChargeCellItem *item;

// 类别id或者成员id
@property(nonatomic, strong) NSString *Id;

// 账本id
@property(nonatomic, strong) NSString *booksId;

// 是成员流水还是类别流水
@property (nonatomic) BOOL isMemberCharge;

// 查询周期内的流水
@property (nonatomic, strong) SSJDatePeriod *period;

@end
