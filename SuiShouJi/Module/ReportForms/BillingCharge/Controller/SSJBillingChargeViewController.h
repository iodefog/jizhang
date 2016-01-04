//
//  SSJBillingChargeViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  记账流水

#import "SSJBaseViewController.h"

@interface SSJBillingChargeViewController : SSJBaseViewController

// 收支类型ID，必传
@property (nonatomic, copy) NSString *billTypeID;

// 查询哪年的流水记录，必传
@property (nonatomic) NSInteger year;

// 查询哪个月的流水记录，如果不传就查询整年的记录
@property (nonatomic) NSInteger month;

@end
