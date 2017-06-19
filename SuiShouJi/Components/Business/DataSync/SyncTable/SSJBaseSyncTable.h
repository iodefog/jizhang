//
//  SSJBaseSyncTable.h
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJDatabaseQueue.h"

@interface SSJBaseSyncTable : NSObject

///----------------------------------
/// @name 子类必需覆写的方法
///----------------------------------

/**
 *  返回对应的表名，子类必需覆写
 *
 *  @return 表名
 */
+ (NSString *)tableName;

///----------------------------------
/// @name 根据情况子类可覆写的方法
///----------------------------------

/**
 *  返回对应的表的列名，子类必需覆写
 *
 *  @return 返回对应的表的列名
 */
+ (NSArray *)columns;

/**
 *  返回对应的表的主键，子类必需覆写
 *
 *  @return 对应的表的主键
 */
+ (NSArray *)primaryKeys;

/**
 *  返回查询需要同步的记录的其它条件，根据需要子类可以覆写
 *
 *  @return (BOOL) 查询需要同步的记录的其它条件
 */
+ (NSString *)queryRecordsForSyncAdditionalCondition;

/**
 *  返回更新版本号需要的额外条件，根据需要子类可以覆写
 *
 *  @return 更新版本号需要的额外条件
 */
+ (NSString *)updateSyncVersionAdditionalCondition;

/**
 *  返回合并记录的插入条件，根据需要子类可以覆写
 *
 *  @param record 要合并的记录数据
 *  @return (NSString *) 合并记录的其它条件
 */
+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error;

/**
 *  查询需要同步的记录
 *
 *  @param db FMDatabase实例
 *  @return 需要同步的记录
 */
+ (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error;

/**
 *  更新表中版本号大于当前同步版本号的记录的版本号
 *
 *  @param version 当前同步版本号
 *  @param toVersion 新版本号
 *  @param db FMDatabase实例
 *  @return 是否更新成功
 */
+ (BOOL)updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:(int64_t)newVersion forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error;

/**
 *  合并记录到相应的表中
 *
 *  @param db FMDatabase实例
 *  @return 是否合并成功
 */
+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error;

/**
 返回本地数据库的字段名和服务端数据库字段名的映射；
 父类返回nil，子类根据情况复写此方法；
 key:本地数据库字段名 value:服务端数据库字段名
 此举是为了填坑，本地数据库字段名命名错误导致相应的数据无法同步

 @return
 */
+ (NSDictionary *)fieldMapping;

@end
