//
//  SSJBudgetListCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@class SSJBudgetModel;

@interface SSJBudgetListCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *budgetID;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *billTypeName;

@property (nonatomic, copy) NSString *period;

@property (nonatomic, copy) NSAttributedString *expend;

@property (nonatomic, copy) NSAttributedString *budget;

@property (nonatomic, copy) NSString *progressColorValue;

@property (nonatomic) CGFloat expendValue;

@property (nonatomic) CGFloat budgetValue;

// 是否总预算
@property (nonatomic) BOOL isMajor;

/**
 根据预算模型和收支类别信息映射表返回对应的Cell模型；
 ⚠️注意：如果预算依赖的收支类别都不存在，此方法会返回nil

 @param model 预算模型
 @param mapping 收支类别信息映射表；结构@{类别ID:@{@"name":类别名称, @"color":类别颜色}}
 @return Cell模型
 */
+ (instancetype)cellItemWithBudgetModel:(SSJBudgetModel *)model billTypeMapping:(NSDictionary *)mapping;

@end
