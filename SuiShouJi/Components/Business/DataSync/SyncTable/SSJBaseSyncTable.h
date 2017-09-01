//
//  SSJBaseSyncTable.h
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJDatabaseQueue.h"

@protocol SSJBaseSyncTableInfo <NSObject>

@required
/**
 *  返回对应的表名
 *
 *  @return 表名
 */
+ (NSString *)tableName;

@optional
/**
 *  返回对应的表的列名
 *
 *  @return 返回对应的表的列名
 */
+ (NSSet *)columns;

/**
 *  返回对应的表的主键
 *
 *  @return 对应的表的主键
 */
+ (NSSet *)primaryKeys;

/**
 返回本地数据库的字段名和服务端数据库字段名的映射；
 父类返回nil，子类根据情况复写此方法；
 key:本地数据库字段名 value:服务端数据库字段名
 此举是为了填坑，本地数据库字段名命名错误导致相应的数据无法同步
 
 @return
 */
+ (NSDictionary *)fieldMapping;

@end



@interface SSJBaseSyncTable : NSObject <SSJBaseSyncTableInfo>

/**
 合并数据时是否已删除数据为准；
 默认返回YES；
 如果返回YES，就以删除的数据为准，没有删除的数据，就以writedate最新的数据为准；
 如果返回NO，就只以writedate最新的数据为准
 */
@property (nonatomic) BOOL subjectToDeletion;

/**
 便捷初始化方法

 @return
 */
+ (instancetype)table;

/**
 *  查询需要同步的记录
 *
 *  @param db FMDatabase实例
 *  @return 需要同步的记录
 */
- (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId
                                   inDatabase:(FMDatabase *)db
                                        error:(NSError **)error;

/**
 合并记录到相应的表中，根据需要子类可以覆写
 
 @param records 存储记录的数组
 @param userId 当前同步的用户id
 @param db 数据库对象
 @param error 错误描述对象
 @return 是否合并成功
 */
- (BOOL)mergeRecords:(NSArray *)records
           forUserId:(NSString *)userId
          inDatabase:(FMDatabase *)db
               error:(NSError **)error;

/**
 根据返回值决定是否要合并此记录，根据需要子类可以覆写
 
 @param record 要合并的记录数据
 @param userId 当前同步的用户id
 @param db 数据库对象
 @param error 错误描述对象
 @return 是否应该合并
 */
- (BOOL)shouldMergeRecord:(NSDictionary *)record
                forUserId:(NSString *)userId
               inDatabase:(FMDatabase *)db
                    error:(NSError **)error;

/**
 更新返回的数据
 
 @param record 服务端返回的数据
 @param condition 更新条件；即主键是否相等的条件
 @param userId 当前同步的用户id
 @param db 数据库对象
 @param error 错误描述对象
 @return 是否合并成功
 */
- (BOOL)updateRecord:(NSDictionary *)record
           condition:(NSString *)condition
           forUserId:(NSString *)userId
          inDatabase:(FMDatabase *)db
               error:(NSError **)error;

/**
 插入返回的数据
 
 @param record 服务端返回的数据
 @param userId 当前同步的用户id
 @param db 数据库对象
 @param error 错误描述对象
 @return 是否合并成功
 */
- (BOOL)insertRecord:(NSDictionary *)record
           forUserId:(NSString *)userId
          inDatabase:(FMDatabase *)db
               error:(NSError **)error;

/**
 *  更新表中版本号大于当前同步版本号的记录的版本号
 *
 *  @param version 当前同步版本号
 *  @param toVersion 新版本号
 *  @param db FMDatabase实例
 *  @return 是否更新成功
 */
- (BOOL)updateVersionOfRecordModifiedDuringSync:(int64_t)newVersion
                                      forUserId:(NSString *)userId
                                     inDatabase:(FMDatabase *)db
                                          error:(NSError **)error;

@end
