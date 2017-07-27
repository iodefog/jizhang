//
//  SSJBillTypeLibraryModel.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJBillTypeCategoryModel;

@interface SSJBillTypeLibraryModel : NSObject

- (NSArray<SSJBillTypeCategoryModel *> *)incomeCategories;

- (NSArray<SSJBillTypeCategoryModel *> *)expenseCategoriesWithBooksType:(SSJBooksType)booksType;

@end
