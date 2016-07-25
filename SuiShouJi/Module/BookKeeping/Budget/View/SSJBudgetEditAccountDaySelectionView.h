//
//  SSJBudgetEditAccountDaySelectionView.h
//  SuiShouJi
//
//  Created by old lang on 16/7/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBudgetConst.h"

@interface SSJBudgetEditAccountDaySelectionView : UIControl

@property (nonatomic) SSJBudgetPeriodType periodType;

@property (nonatomic, copy) void (^sureAction)(SSJBudgetEditAccountDaySelectionView *);

@property (nonatomic, strong, readonly) NSDate *beginDate;

@property (nonatomic, strong, readonly) NSDate *endDate;

@property (nonatomic, readonly) BOOL endOfMonth;

- (void)show;

- (void)dismiss;

@end
