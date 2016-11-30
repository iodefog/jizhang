//
//  SSJRepaymentModel.h
//  SuiShouJi
//
//  Created by ricky on 2016/11/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJRepaymentModel : SSJBaseItem

// 还款id
@property(nonatomic, strong) NSString *repaymentId;

// 信用卡id
@property(nonatomic, strong) NSString *cardId;

// 还款申请时间(分期还款时用)
@property(nonatomic, strong) NSString *applyDate;

// 还款来源资金账户id
@property(nonatomic, strong) NSString *repaymentSourceFoundId;

// 还款金额
@property(nonatomic, strong) NSDecimalNumber *repaymentMoney;

// 分期期数
@property(nonatomic) NSInteger instalmentCout;

// 分期手续费
@property(nonatomic, strong) NSDecimalNumber *poundageRate;

// 备注
@property(nonatomic, strong) NSString *memo;

@end
