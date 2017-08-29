//
//  SSJRecycleHelper.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJRecycleListModel;
@class FMDatabase;

@interface SSJRecycleHelper : NSObject

/**
 查询回收站数据

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)queryRecycleListModelsWithSuccess:(void(^)(NSArray<SSJRecycleListModel *> *models))success
                                  failure:(nullable void(^)(NSError *error))failure;

/**
 还原回收站数据

 @param recycleIDs 要还原的数据ID
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)recoverRecycleIDs:(NSArray<NSString *> *)recycleIDs
                  success:(nullable void(^)())success
                  failure:(nullable void(^)(NSError *error))failure;

/**
 清除回收站数据

 @param recycleIDs 要清除的数据ID
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)clearRecycleIDs:(NSArray<NSString *> *)recycleIDs
                success:(nullable void(^)())success
                failure:(nullable void(^)(NSError *error))failure;

/**
 新建回收站记录

 @param ID 删除数据的主键
 @param recycleType 回收站数据类型
 @param writeDate 删除时间
 @param db 数据库对象
 @param error 错误对象
 @return 是否执行成功
 */
+ (BOOL)createRecycleRecordWithID:(NSString *)ID
                      recycleType:(SSJRecycleType)recycleType
                        writeDate:(NSString *)writeDate
                         database:(FMDatabase *)db
                            error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
