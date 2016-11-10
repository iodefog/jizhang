//
//  SSJLoanChargeAddOrEditViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJLoanChargeModel;

@interface SSJLoanChargeAddOrEditViewController : SSJBaseViewController

/**
 借贷流水复合模型，如果不传是新建，反之就是编辑
 */
@property (nonatomic, copy) SSJLoanChargeModel *model;

@end

NS_ASSUME_NONNULL_END
