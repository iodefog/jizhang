//
//  SSJCreateOrEditBillTypeHelper.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJBillTypeCategoryModel;

@interface SSJCreateOrEditBillTypeHelper : NSObject

+ (NSArray<SSJBillTypeCategoryModel *> *)incomeCategories;

+ (NSArray<SSJBillTypeCategoryModel *> *)expenseCategoriesWithBooksType:(SSJBooksType)booksType;

@end
