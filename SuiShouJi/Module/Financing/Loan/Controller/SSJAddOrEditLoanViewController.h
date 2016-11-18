//
//  SSJAddOrEditLoanViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJLoanModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJAddOrEditLoanViewController : SSJBaseViewController

/**
 借贷类型
 注意：新建必须传值，编辑不用传
 */
@property (nonatomic) SSJLoanType type;

/**
 借贷模型
 注意：新建不用传，编辑必须传
 */
@property (nonatomic, copy, nullable) SSJLoanModel *loanModel;

/**
 借贷产生的流水列表
 注意：新建不用传，编辑必须传
 */
@property (nonatomic, copy, nullable) NSArray <SSJLoanCompoundChargeModel *>*chargeModels;

/**
 是否从选择账户类型页面进入
 注意：从选择账户类型页面进入时传YES，其他入口进入不用传
 */
@property (nonatomic) BOOL enterFromFundTypeList;

@end

NS_ASSUME_NONNULL_END
