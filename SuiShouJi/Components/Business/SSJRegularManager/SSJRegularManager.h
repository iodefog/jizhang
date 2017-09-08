//
//  SSJRegularManager.h
//  SuiShouJi
//
//  Created by old lang on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

NS_ASSUME_NONNULL_BEGIN

@interface SSJRegularManager : NSObject

/**
 *  注册定期任务通知（定期记账、定期预算、周期转账）
 */
+ (void)registerRegularTaskNotification;

/**
 *  执行定期任务（检测是否需要补充记账流水、预算、周期转账），在收到本地通知的方法中调用application:didReceiveLocalNotification:
 *
 *  @param notification 本地通知对象，传入application:didReceiveLocalNotification:中的notification参数
 */
+ (void)performRegularTaskWithLocalNotification:(UILocalNotification *)notification;

/**
 同步补充循环记录（周期记账、周期转账、预算）

 @param userId 用户id
 @return 是否成功
 */
+ (BOOL)supplementCycleRecordsForUserId:(NSString *)userId;

/**
 异步补充循环记录（周期记账、周期转账、预算）

 @param userId 用户id
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)supplementCycleRecordsForUserId:(NSString *)userId success:(nullable void(^)())success failure:(nullable void (^)(NSError *error))failure;

/**
 *  根据周期记账补充记账流水
 *
 *  @param BOOL 是否补充成功
 */
+ (BOOL)supplementBookkeepingForUserId:(NSString *)userId inDatabase:(FMDatabase *)db;

/**
 *  补充相应用户的预算流水
 *
 *  @param BOOL 是否补充成功
 */
+ (BOOL)supplementBudgetForUserId:(NSString *)userId inDatabase:(FMDatabase *)db;

/**
 *  根据周期转账补充记账流水
 *
 *  @param BOOL 是否补充成功
 */
+ (BOOL)supplementCyclicTransferForUserId:(NSString *)userId inDatabase:(FMDatabase *)db;

+ (void)regularDistributedInterestSuccess:(void (^)())success failure:(void (^)(NSError * error))failure;

@end

NS_ASSUME_NONNULL_END
