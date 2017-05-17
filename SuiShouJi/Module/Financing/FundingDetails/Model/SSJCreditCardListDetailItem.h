//
//  SSJCreditCardListDetailItem.h
//  SuiShouJi
//
//  Created by ricky on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJCreditCardListDetailItem : SSJBaseCellItem

//当前周期
@property(nonatomic, strong) NSString *datePeriod;

//当前月份
@property(nonatomic, strong) NSString *month;

//当周期支出
@property (nonatomic) double income;

//当周期收入
@property(nonatomic) double expenture;

//还款日
@property (nonatomic) NSInteger repaymentDay;

//账单日
@property(nonatomic) NSInteger billingDay;

//当周期流水
@property(nonatomic, strong) NSMutableArray *chargeArray;

//此行是否展开
@property(nonatomic) BOOL isExpand;

@property(nonatomic) double instalmentMoney;

@property(nonatomic) double repaymentMoney;

@property(nonatomic) double repaymentForOtherMonthMoney;

@property(nonatomic) double moneyNeedToRepay;

@end
