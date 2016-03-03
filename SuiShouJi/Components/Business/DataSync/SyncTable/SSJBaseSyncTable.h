//
//  SSJBaseSyncTable.h
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "SSJDataSyncHelper.h"

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

///----------------------------------
/// @name 根据情况子类可覆写的方法
///----------------------------------

/**
 *  返回可选的列名，根据需要子类可以覆写
 *
 *  @return 返回对应的表的列名
 */
+ (NSArray *)optionalColumns;

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
+ (BOOL)shouldMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db error:(NSError **)error;

///----------------------------------
/// @name 只能调用，子类不可覆写！！！
///----------------------------------

/**
 *  查询需要同步的记录
 *
 *  @param db FMDatabase实例
 *  @return 需要同步的记录
 */
+ (NSArray *)queryRecordsNeedToSyncInDatabase:(FMDatabase *)db error:(NSError **)error;

/**
 *  更新表中版本号大于当前同步版本号的记录的版本号
 *
 *  @param version 当前同步版本号
 *  @param toVersion 新版本号
 *  @param db FMDatabase实例
 *  @return 是否更新成功
 */
+ (BOOL)updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:(int64_t)newVersion inDatabase:(FMDatabase *)db error:(NSError **)error;

/**
 *  合并记录到相应的表中
 *
 *  @param db FMDatabase实例
 *  @return 是否合并成功
 */
+ (BOOL)mergeRecords:(NSArray *)records inDatabase:(FMDatabase *)db error:(NSError **)error;

@end
