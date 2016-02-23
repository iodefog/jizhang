//
//  SSJBudgetModel.h
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJBudgetModel : NSObject

//  预算id
@property (nonatomic, copy) NSString *ID;

//  用户id
@property (nonatomic, copy) NSString *userId;

//  预算类型 1:周预算 2:月预算 3:年预算
@property (nonatomic) int type;

//  预算金额
@property (nonatomic) double budgetMoney;

//  提醒金额
@property (nonatomic) double remindMoney;

//  支出金额
@property (nonatomic) double payMoney;

//  预算开始时间
@property (nonatomic, copy) NSString *beginDate;

//  预算结束时间
@property (nonatomic, copy) NSString *endDate;

//  是否自动续用
@property (nonatomic) BOOL isAutoContinued;

@end
