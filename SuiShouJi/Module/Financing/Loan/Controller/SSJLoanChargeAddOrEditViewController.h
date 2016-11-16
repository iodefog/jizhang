//
//  SSJLoanChargeAddOrEditViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

// 收款、追加编辑／新建

#import "SSJBaseViewController.h"
#import "SSJLoanCompoundChargeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJLoanChargeAddOrEditViewController : SSJBaseViewController

/**
 是否编辑
 */
@property (nonatomic) BOOL edited;

/**
 指定是追加还是还款，只有SSJLoanCompoundChargeTypeRepayment和SSJLoanCompoundChargeTypeAdd两个值有效
 注意：新建必传，编辑不传
 */
@property (nonatomic) SSJLoanCompoundChargeType chargeType;

/**
 借贷id
 注意：新建必传，编辑不传
 */
@property (nonatomic, copy, nullable) NSString *loanId;

/**
 流水id，根据此id查询其余借贷流水，必须是借贷产生的流水
 注意：新建不传，编辑必传
 */
@property (nonatomic, copy, nullable) NSString *chargeId;

@end

NS_ASSUME_NONNULL_END
