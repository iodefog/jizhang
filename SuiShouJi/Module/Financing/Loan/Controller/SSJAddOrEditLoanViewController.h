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

// 如果loanModel的ID为空就是新建，反之是编辑;新建的话loanModel的fundID、type必须传值
@property (nonatomic, copy) SSJLoanModel *loanModel;

@property (nonatomic) BOOL enterFromFundTypeList;

@end

NS_ASSUME_NONNULL_END
