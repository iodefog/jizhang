//
//  SSJLoanChangeChargeSelectionControl.h
//  SuiShouJi
//
//  Created by old lang on 16/11/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJLoanChargeModel.h"

@interface SSJLoanChangeChargeSelectionControl : UIView

@property (nonatomic, readonly) SSJLoanType loanType;

/**
 选组收款／还款、追加借出／欠款的回调；value只有两个有效值，SSJLoanCompoundChargeTypeRepayment和SSJLoanCompoundChargeTypeAdd
 */
@property (nonatomic, copy) void (^selectionHandle)(SSJLoanCompoundChargeType value);

- (instancetype)initWithLoanType:(SSJLoanType)loanType;

- (void)show;

- (void)updateAppearance;

@end
