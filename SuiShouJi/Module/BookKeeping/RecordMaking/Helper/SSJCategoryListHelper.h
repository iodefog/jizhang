//
//  SSJCategoryListHelper.h
//  SuiShouJi
//
//  Created by ricky on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJRecordMakingCategoryItem.h"

@interface SSJCategoryListHelper : NSObject

+ (void)queryForCategoryListWithCountForEachPage:(int)count IncomeOrExpenture:(int)incomeOrExpenture Success:(void(^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

@end
