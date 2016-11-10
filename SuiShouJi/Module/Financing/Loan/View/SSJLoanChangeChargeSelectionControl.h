//
//  SSJLoanChangeChargeSelectionControl.h
//  SuiShouJi
//
//  Created by old lang on 16/11/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJLoanChargeModel.h"


/**
 选择变更流水类型
 
 - SSJLoanChangeChargeSelectionRepayment: 还款／欠款
 - SSJLoanChangeChargeSelectionAdd: 追加借出／欠款
 */
typedef NS_ENUM(NSUInteger, SSJLoanChangeChargeSelectionValue) {
    SSJLoanChangeChargeSelectionRepayment,
    SSJLoanChangeChargeSelectionAdd
};

@interface SSJLoanChangeChargeSelectionControl : UIView

@property (nonatomic, readonly) SSJLoanType loanType;

@property (nonatomic, copy) void (^selectionHandle)(SSJLoanChangeChargeSelectionValue value);

- (instancetype)initWithLoanType:(SSJLoanType)loanType;

- (void)show;

- (void)updateAppearance;

@end
