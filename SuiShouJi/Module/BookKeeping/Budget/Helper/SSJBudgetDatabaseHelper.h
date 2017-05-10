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

@class SSJBudgetListCellItem;
@class SSJBudgetBillTypeSelectionCellItem;

NS_ASSUME_NONNULL_BEGIN

// 预算模型key
extern NSString *const SSJBudgetModelKey;

// 预算详情header视图模型key
extern NSString *const SSJBudgetDetailHeaderViewItemKey;

// 预算详情列表key
extern NSString *const SSJBudgetListCellItemKey;

// 月预算编号key
extern NSString *const SSJBudgetIDKey;

// 月预算标题key
extern NSString *const SSJBudgetPeriodKey;

// 冲突的预算类别
extern NSString *const SSJBudgetConflictBillIdsKey;

// 冲突的总预算金额
extern NSString *const SSJBudgetConflictMajorBudgetMoneyKey;

// 冲突的分预算总金额
extern NSString *const SSJBudgetConflictSecondaryBudgetMoneyKey;

// 冲突的总预算模型
extern NSString *const SSJBudgetConflictBudgetModelKey;


@interface SSJBudgetDatabaseHelper : NSObject

/**
 *  查询当前有效的预算列表
 *
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForBudgetCellItemListWithSuccess:(void(^)(NSArray<SSJBudgetListCellItem *> *result))success
                                      failure:(void (^)(NSError * _Nullable error))failure;

/**
 *  查询当前有效的预算列表
 *
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForCurrentBudgetListWithSuccess:(void(^)(NSArray<SSJBudgetModel *> *result))success
                                     failure:(void (^)(NSError *error))failure;


/**
 *  查询预算详情
 *
 *  @param ID        预算编号
 *  @param success   查询成功的回调；
                     参数result的结构：@{SSJBudgetModelKey:SSJBudgetModel实例,
                                      SSJBudgetDetailHeaderViewItemKey:SSJBudgetDetailHeaderViewItem实例,
                                      SSJBudgetListCellItemKey:@[SSJReportFormsItem实例]}
 *  @param failure   查询失败的回调
 */
+ (void)queryForBudgetDetailWithID:(NSString *)ID
                           success:(void(^)(NSDictionary *result))success
                           failure:(void (^)(NSError * _Nullable error))failure;

/**
 *  删除预算
 *
 *  @param ID        预算编号
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (void)deleteBudgetWithID:(NSString *)ID
                   success:(void(^)())success
                   failure:(void (^)(NSError * _Nullable error))failure;

/**
 *  查询截止到当前周期的预算id列表
 *
 *  @param type      查询的预算类型
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForBudgetIdListWithType:(SSJBudgetPeriodType)type
                             billIds:(NSArray *)billIds
                             success:(void(^)(NSDictionary *result))success
                             failure:(void (^)(NSError *error))failure;

/**
 *  根据预算模型查询类别名称与类别id的映射表；映射表结构：@{@"1000":@"餐饮", @"1001":@"烟酒"}
 *
 *  @param model     查询的预算模型
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryBillTypeMapWithSuccess:(void(^)(NSDictionary *billTypeMap))success
                            failure:(void (^)(NSError *error))failure;

/**
 *  按顺序监测是否和其他预算有周期、类别、金额冲突；详细检测过程：
 *  1.检测相同类型、账本、类别预算有没有周期冲突
 *  2.如果保存的是分预算，检测相同类型、账本、周期的其它预算有没有相同的类别
 *  3.检测相同类型、账本、周期的各个分预算总金额不能大于总预算金额
 *
 *  @param model     检测的预算模型
 *  @param success   检测成功的回调；
                     code解释:
                         0:没有冲突
                         1:有周期冲突的预算
                         2:有类别冲突的预算 
                         3:设置的总预算金额小于分预算金额 
                         4:设置的分预算金额大于总预算金额
 
                     additionInfo:
                         code为0，nil
                         code为1，nil
                         code为2，@{SSJBudgetConflictBillIdsKey:@[类别id, ...]} 
                         code为3，@{SSJBudgetConflictMajorBudgetMoneyKey:@(总预算金额), 
                                   SSJBudgetConflictSecondaryBudgetMoneyKey:@(分预算总金额)}
                         code为4，@{SSJBudgetConflictMajorBudgetMoneyKey:@(总预算金额),
                                   SSJBudgetConflictSecondaryBudgetMoneyKey:@(分预算总金额),
                                   SSJBudgetConflictBudgetModelKey:总预算模型}
 *  @param failure   检测失败的回调
 */
+ (void)checkIfConflictBudgetModel:(SSJBudgetModel *)model
                           success:(void(^)(int code, NSDictionary *additionInfo))success
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
 *  存储预算列表
 *
 *  @param model     装载预算模型的数组
 *  @param success   存储成功的回调
 *  @param failure   存储失败的回调
 */
+ (void)saveBudgetModels:(NSArray <SSJBudgetModel *>*)models
                 success:(void(^)())success
                 failure:(void (^)(NSError *error))failure;

+ (void)queryBookNameForBookId:(NSString *)ID
                       success:(void(^)(NSString *bookName))success
                       failure:(void(^)(NSError *error))failure;

/**
 *  查询支出类别列表
 *
 *  @param model     预算模型
 *  @param booksId   账本id，如果为nil，查询当前账本
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryBudgetBillTypeSelectionItemListWithSelectedTypeList:(NSArray *)typeList
                                                         booksId:(nullable NSString *)booksId
                                                         success:(void(^)(NSArray <SSJBudgetBillTypeSelectionCellItem *>*list))success
                                                         failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
