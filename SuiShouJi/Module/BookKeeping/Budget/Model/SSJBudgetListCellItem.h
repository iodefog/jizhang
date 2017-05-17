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

+ (instancetype)cellItemWithBudgetModel:(SSJBudgetModel *)model billTypeMapping:(NSDictionary *)mapping;

@end
