//
//  SSJSyncTable.h
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface SSJSyncTable : NSObject

/**
 *  返回最近一次同步成功的版本号
 *
 *  @param db FMDatabase实例
 *  @return 最近一次同步成功的版本号
 */
+ (int64_t)lastSuccessSyncVersionInDatabase:(FMDatabase *)db;

/**
 *  插入正在同步的版本号
 *
 *  @param version 正在同步的版本号
 *  @param db FMDatabase实例
 *  @return 是否插入成功
 */
+ (BOOL)insertUnderwaySyncVersion:(int64_t)version inDatabase:(FMDatabase *)db;

/**
 *  插入同步成功的版本号
 *
 *  @param version 同步成功的版本号
 *  @param db FMDatabase实例
 *  @return 是否插入成功
 */
+ (BOOL)insertSuccessSyncVersion:(int64_t)version inDatabase:(FMDatabase *)db;

@end
