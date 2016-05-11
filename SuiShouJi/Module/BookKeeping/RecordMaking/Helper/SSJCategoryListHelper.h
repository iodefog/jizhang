//
//  SSJCategoryListHelper.h
//  SuiShouJi
//
//  Created by ricky on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJRecordMakingBillTypeSelectionCellItem;
@class SSJRecordMakingCategoryItem;

@interface SSJCategoryListHelper : NSObject

/**
 *  查询所有的启用的记账类型
 *
 *  @param incomeOrExpenture 收入还是支出(1为支出,0为收入)
 *  @param success           查询成功的回调
 *  @param failure           查询失败的回调
 */
+ (void)queryForCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                          Success:(void(^)(NSMutableArray<SSJRecordMakingBillTypeSelectionCellItem *> *result))success
                                          failure:(void (^)(NSError *error))failure;

/**
 *  删除一个记账类型
 *
 *  @param categoryId 记账类型id
 *  @param success    删除成功的回调
 *  @param failure    删除失败的回调
 */
+ (void)deleteCategoryWithCategoryId:(NSString *)categoryId
                             Success:(void(^)(BOOL result))success
                             failure:(void (^)(NSError *error))failure;

/**
 *  查询所有的未启用的记账类型
 *
 *  @param incomeOrExpenture 收入还是支出(1为支出,0为收入)
 *  @param success           查询成功的回调
 *  @param failure           查询失败的回调
 */
+ (void)queryForUnusedCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                                success:(void(^)(NSMutableArray<SSJRecordMakingCategoryItem *> *result))success
                                                failure:(void (^)(NSError *error))failure;

/**
 *  查询自定义收支类型图标
 *
 *  @param incomeOrExpenture 收入还是支出(1为支出,0为收入)
 *  @param success    查询成功的回调
 *  @param failure    查询失败的回调
 */
+ (void)queryCustomCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                             success:(void(^)(NSArray<SSJRecordMakingCategoryItem *> *items))success
                                             failure:(void (^)(NSError *error))failure;

+ (NSArray *)payOutColors;

+ (NSArray *)incomeColors;

@end
