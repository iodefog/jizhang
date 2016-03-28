//
//  SSJBudgetDetailPeriodSwitchControl.h
//  SuiShouJi
//
//  Created by old lang on 16/3/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  预算周期切换控件

#import <UIKit/UIKit.h>
#import "SSJBudgetConst.h"

@interface SSJBudgetDetailPeriodSwitchControl : UIControl

@property (nonatomic) SSJBudgetPeriodType periodType;

@property (nonatomic, strong) NSDate *lastDate;

@property (nonatomic, strong) NSDate *currentDate;

@end
