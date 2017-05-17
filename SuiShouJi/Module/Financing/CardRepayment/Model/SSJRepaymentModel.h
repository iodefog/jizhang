//
//  SSJRepaymentModel.h
//  SuiShouJi
//
//  Created by ricky on 2016/11/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJRepaymentModel : SSJBaseCellItem <NSCopying>

// 还款id
@property(nonatomic, strong) NSString *repaymentId;

// 信用卡id
@property(nonatomic, strong) NSString *cardId;

// 信用卡账单日
@property(nonatomic) NSInteger cardBillingDay;

// 信用卡还款日
@property(nonatomic) NSInteger cardRepaymentDay;

// 信用卡名称
@property(nonatomic, strong) NSString *cardName;

// 还款申请时间(分期还款时用)
@property(nonatomic, strong) NSDate *applyDate;

// 还款的账单月份
@property(nonatomic, strong) NSDate *repaymentMonth;

// 还款来源资金账户id
@property(nonatomic, strong) NSString *repaymentSourceFoundId;

// 还款来源资金账户名称
@property(nonatomic, strong) NSString *repaymentSourceFoundName;

// 还款来源资金账户图标
@property(nonatomic, strong) NSString *repaymentSourceFoundImage;

// 还款金额
@property(nonatomic, strong) NSDecimalNumber *repaymentMoney;

// 还款的流水id
@property(nonatomic, strong) NSString *repaymentChargeId;

// 转账来源的流水id
@property(nonatomic, strong) NSString *sourceChargeId;

// 分期期数
@property(nonatomic) NSInteger instalmentCout;

// 当前期数
@property(nonatomic) NSInteger currentInstalmentCout;

// 分期手续费
@property(nonatomic, strong) NSDecimalNumber *poundageRate;

// 备注
@property(nonatomic, strong) NSString *memo;

@end
