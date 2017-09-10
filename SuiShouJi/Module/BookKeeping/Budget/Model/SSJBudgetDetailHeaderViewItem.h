//
//  SSJBudgetDetailHeaderViewItem.h
//  SuiShouJi
//
//  Created by old lang on 16/9/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJBudgetModel;
@class SSJPercentCircleViewItem;

// 类别名称key
extern NSString *const SSJBudgetDetailBillInfoNameKey;

// 类别颜色key
extern NSString *const SSJBudgetDetailBillInfoColorKey;

@interface SSJBudgetDetailHeaderViewItem : NSObject

// 是否总预算
@property (nonatomic) BOOL isMajor;

// 是否历史预算
@property (nonatomic) BOOL isHistory;

// 预算金额顶部标题
@property (nonatomic, copy) NSString *budgetMoneyTitle;

// 预算金额
@property (nonatomic, copy) NSString *budgetMoneyValue;

// 距结算日定不标题
@property (nonatomic, copy) NSString *intervalTitle;

// 距结算日天数
@property (nonatomic, copy) NSString *intervalValue;

// 预算金额
@property (nonatomic) CGFloat budgetMoney;

// 支出金额
@property (nonatomic) CGFloat expendMoney;

// 进度条颜色
@property (nonatomic, copy) NSString *progressColorValue;

// 当前预算已花费金额
@property (nonatomic, copy) NSString *payment;

// 每天可以花费金额、超支金额
@property (nonatomic, copy) NSAttributedString *payOrOverrun;

// 历史预算的已花费金额
@property (nonatomic, copy) NSAttributedString *historyPayment;

// 预算金额（只在历史预算中显示）
@property (nonatomic, copy) NSAttributedString *historyBudget;

// 预算类别
@property (nonatomic, copy) NSString *billTypeNames;

@property (nonatomic, strong) NSArray <SSJPercentCircleViewItem *>*circleItems;

+ (instancetype)itemWithBudgetModel:(SSJBudgetModel *)model billMapping:(NSDictionary *)billMapping;

@end
