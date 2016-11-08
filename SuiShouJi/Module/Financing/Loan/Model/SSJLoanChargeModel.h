//
//  SSJLoanChargeModel.h
//  SuiShouJi
//
//  Created by old lang on 16/11/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;

/**
 借贷类型

 - SSJLoanTypeLend: 借入
 - SSJLoanTypeLend: 借出
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

@property (nonatomic, copy) NSString *fundId;

@property (nonatomic, copy) NSString *billId;

@property (nonatomic, copy) NSString *loanId;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *memo;

@property (nonatomic, copy) NSDate *billDate;

@property (nonatomic, copy) NSDate *writeDate;

@property (nonatomic) double money;

@property (nonatomic) SSJLoanType type;

@property (nonatomic) SSJLoanCompoundChargeType chargeType;

@property (nonatomic) BOOL closedOut;

@end
