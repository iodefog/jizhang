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

//typedef NS_ENUM(NSInteger, SSJAddOrEditLoanViewControllerEntry) {
//    SSJAddOrEditLoanViewControllerEntryLoanList,        // 借贷列表
//    SSJAddOrEditLoanViewControllerEntryFundTypeList     // 资金类型列表
//};

@interface SSJAddOrEditLoanViewController : SSJBaseViewController

@property (nonatomic, copy) SSJLoanModel *loanModel;

@property (nonatomic) BOOL enterFromFundTypeList;

@end

NS_ASSUME_NONNULL_END
