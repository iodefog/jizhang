//
//  SSJBudgetHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBudgetModel.h"
#import "SSJBudgetTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

//  预算模型key
extern NSString *const SSJBudgetModelKey;

//  预算图表模型key
extern NSString *const SSJBudgetCircleItemsKey;

//  月预算编号key
extern NSString *const SSJBudgetMonthIDKey;

//  月预算标题key
extern NSString *const SSJBudgetMonthTitleKey;


@interface SSJBudgetDatabaseHelper : NSObject

/**
 *  查询当前有效的预算列表
 *
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForCurrentBudgetListWithSuccess:(void(^)(NSArray<SSJBudgetModel *> *result))success
                                     failure:(void (^)(NSError * _Nullable error))failure;

/**
 *  查询预算详情
 *
 *  @param ID        预算编号
 *  @param success   查询成功的回调；
                     参数result的结构：@{SSJBudgetModelKey:SSJBudgetModel实例, SSJBudgetCircleItemsKey:@[SSJPercentCircleViewItem实例]}
 *  @param failure   查询失败的回调
 */
+ (void)queryForBudgetDetailWithID:(NSString *)ID
                           success:(void(^)(NSDictionary *result))success
                           failure:(void (^)(NSError * _Nullable error))failure;

/**
 *  查询月预算id列表
 *
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForMonthBudgetIdListWithSuccess:(void(^)(NSArray<NSDictionary *> *result))success
                                     failure:(void (^)(NSError * _Nullable error))failure;

/**
 *  根据预算模型查询类别名称与类别id的映射表；映射表结构：@{@"餐饮":@"1000", @"烟酒":@"1001"}
 *
 *  @param model     查询的预算模型
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryBillTypeMapWithSuccess:(void(^)(NSDictionary *billTypeMap))success
                            failure:(void (^)(NSError *error))failure;

/**
 *  检测是否有和model冲突的预算（即预算类别、开始时间、预算周期三者都相同）
 *
 *  @param model     检测的预算模型
 *  @param success   检测成功的回调
 *  @param failure   检测失败的回调
 */
+ (void)checkIfConflictBudgetModel:(SSJBudgetModel *)model
                           success:(void(^)(BOOL isConficted))success
                           failure:(void (^)(NSError *error))failure;

/**
 *  存储预算
 *
 *  @param model     存储的预算模型
 *  @param success   存储成功的回调
 *  @param failure   存储失败的回调
 */
+ (void)saveBudgetModel:(SSJBudgetModel *)model
                success:(void(^)())success
                failure:(void (^)(NSError *error))failure;

/**
 *  补充自动续用的预算记录
 *
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (void)supplementBudgetRecordWithSuccess:(void(^)())success
                                  failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
