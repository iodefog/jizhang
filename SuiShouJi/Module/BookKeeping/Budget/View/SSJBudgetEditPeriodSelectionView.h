//
//  SSJBudgetEditPeriodSelectionView.h
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  周期选择

#import <UIKit/UIKit.h>
#import "SSJBudgetConst.h"

@interface SSJBudgetEditPeriodSelectionView : UIControl

@property (nonatomic) SSJBudgetPeriodType periodType;

- (void)show;

- (void)dismiss;

@end
