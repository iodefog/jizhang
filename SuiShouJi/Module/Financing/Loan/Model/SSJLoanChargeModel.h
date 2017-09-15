//
//  SSJLoanChargeModel.h
//  SuiShouJi
//
//  Created by old lang on 16/11/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FMResultSet;

/**
 借贷类型

 - SSJLoanTypeLend: 借出
 - SSJLoanTypeBorrow: 借入（欠款）
 */
typedef NS_ENUM(NSInteger, SSJLoanType) {
    SSJLoanTypeLend,
    SSJLoanTypeBorrow
};

/**
 借贷变更流水类型
 
 - SSJLoanCompoundChargeTypeCreate: 创建借贷产生的流水
 - SSJLoanCompoundChargeTypeBalanceChange: 借贷余额变更产生的流水
 - SSJLoanCompoundChargeTypeRepayment: 还款/收款产生的流水
 - SSJLoanCompoundChargeTypeAdd: 追加借出/欠款产生的流水
 - SSJLoanCompoundChargeTypeCloseOut: 结清产生的流水
 - SSJLoanCompoundChargeTypeInterest: 还款/收款、结清产生的利息流水
 
 */
typedef NS_ENUM(NSUInteger, SSJLoanCompoundChargeType) {
    SSJLoanCompoundChargeTypeCreate,
    SSJLoanCompoundChargeTypeBalanceIncrease,
    SSJLoanCompoundChargeTypeBalanceDecrease,
    SSJLoanCompoundChargeTypeRepayment,
    SSJLoanCompoundChargeTypeAdd,
    SSJLoanCompoundChargeTypeCloseOut,
    SSJLoanCompoundChargeTypeInterest
};

@interface SSJLoanChargeModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *chargeId;

@property (nonatomic, copy, nullable) NSString *fundId;

@property (nonatomic, copy) NSString *billId;

@property (nonatomic, copy) NSString *loanId;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy, nullable) NSString *memo;

@property (nonatomic, copy, nullable) NSString *icon;

@property (nonatomic, strong) NSDate *billDate;

@property (nonatomic, strong) NSDate *writeDate;

// 流水金额
@property (nonatomic) double money;

// 变更前的金额
@property (nonatomic) double oldMoney;

@property (nonatomic) SSJLoanType type;

@property (nonatomic) SSJLoanCompoundChargeType chargeType;

@end

NS_ASSUME_NONNULL_END
