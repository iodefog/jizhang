//
//  SSJBudgetDetailHeaderViewItem.h
//  SuiShouJi
//
//  Created by old lang on 16/9/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJBudgetModel;

extern NSString *const SSJBudgetDetailBillInfoNameKey;

extern NSString *const SSJBudgetDetailBillInfoColorKey;

@interface SSJBudgetDetailHeaderViewItem : NSObject

@property (nonatomic) BOOL isMajor;

@property (nonatomic) BOOL isHistory;

@property (nonatomic, copy) NSString *budgetMoneyTitle;

@property (nonatomic, copy) NSString *budgetMoneyValue;

@property (nonatomic, copy) NSString *intervalTitle;

@property (nonatomic, copy) NSString *intervalValue;

@property (nonatomic) CGFloat waveViewPercent;

@property (nonatomic) CGFloat waveViewMoney;

@property (nonatomic) CGFloat progressViewPercent;

@property (nonatomic) CGFloat progressViewMoney;

@property (nonatomic, copy) NSString *progressColorValue;

//  当前预算已花费金额
@property (nonatomic, copy) NSString *payment;

//  每天可以花费金额、超支金额
@property (nonatomic, copy) NSAttributedString *payOrOverrun;

//  历史预算的已花费金额
@property (nonatomic, copy) NSAttributedString *historyPayment;

//  预算金额（只在历史预算中显示）
@property (nonatomic, copy) NSAttributedString *historyBudget;

+ (instancetype)itemWithBudgetModel:(SSJBudgetModel *)model billMapping:(NSDictionary *)billMapping;

@end
