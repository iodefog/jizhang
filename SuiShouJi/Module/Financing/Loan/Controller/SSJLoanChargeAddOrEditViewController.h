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
 借贷id（注意：新建必传，编辑不传）
 */
@property (nonatomic, copy, nullable) NSString *loanId;

/**
 指定是追加还是还款，只有SSJLoanCompoundChargeTypeRepayment和SSJLoanCompoundChargeTypeAdd两个值有效（注意：无论新建还是编辑必传）
 */
@property (nonatomic) SSJLoanCompoundChargeType chargeType;

/**
 借贷流水复合模型（注意：编辑必传，新建不传）
 */
@property (nonatomic, copy, nullable) SSJLoanCompoundChargeModel *compoundModel;

@end

NS_ASSUME_NONNULL_END
