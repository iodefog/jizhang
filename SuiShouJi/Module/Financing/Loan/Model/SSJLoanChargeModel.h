//
//  SSJLoanChargeModel.h
//  SuiShouJi
//
//  Created by old lang on 16/11/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 借贷变更流水类型

 - SSJLoanChargeTypeCreate: 创建借贷产生的流水
 - SSJLoanChargeTypeBalanceChange: 修改借贷余额产生的流水
 - SSJLoanChargeTypeRepayment: 还款/收款产生的流水
 - SSJLoanChargeTypeAdd: 追加借出/欠款产生的流水
 - SSJLoanChargeTypeCloseOut: 结清产生的流水
 - SSJLoanChargeTypeInterest: 还款/收款、结清产生的利息流水
 
 */
typedef NS_ENUM(NSUInteger, SSJLoanChargeType) {
    SSJLoanChargeTypeCreate,
    SSJLoanChargeTypeBalanceChange,
    SSJLoanChargeTypeRepayment,
    SSJLoanChargeTypeAdd,
    SSJLoanChargeTypeCloseOut,
    SSJLoanChargeTypeInterest
};

@interface SSJLoanChargeModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *chargeId;

@property (nonatomic, copy) NSString *fundId;

@property (nonatomic) double money;

@property (nonatomic, copy) NSDate *billDate;

@property (nonatomic, copy) NSString *memo;

@property (nonatomic) BOOL transferredIn;

@property (nonatomic, copy) SSJLoanChargeModel *partnerModel;

@property (nonatomic, copy) SSJLoanChargeModel *interestModel;

@end
