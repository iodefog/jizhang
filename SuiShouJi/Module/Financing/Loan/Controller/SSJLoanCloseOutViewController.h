//
//  SSJLoanCloseOutViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJLoanModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJLoanCloseOutViewController : SSJBaseViewController

@property (nonatomic, copy) SSJLoanModel *loanModel;

@property (nonatomic, copy) NSArray <SSJLoanCompoundChargeModel *>*chargeModels;

@end

NS_ASSUME_NONNULL_END
