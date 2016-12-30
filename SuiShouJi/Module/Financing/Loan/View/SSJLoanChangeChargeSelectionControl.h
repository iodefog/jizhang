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


/**
 选组收款／还款、追加借出／欠款的回调；value只有两个有效值，SSJLoanCompoundChargeTypeRepayment和SSJLoanCompoundChargeTypeAdd
 */
@property (nonatomic, copy) void (^selectionHandle)(NSString *title);

- (instancetype)initWithTitles:(NSArray *)titles;

- (void)setAttributtedText:(NSAttributedString *)attributedtext forIndex:(NSInteger)index;

- (void)show;

- (void)updateAppearance;

@end
