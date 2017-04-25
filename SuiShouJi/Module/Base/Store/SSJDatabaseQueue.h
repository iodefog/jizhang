//
//  SSJDatabaseQueue.h
//  SuiShouJi
//
//  Created by old lang on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "FMDatabaseQueue.h"
#import "SSJDatabase.h"

@interface SSJDatabaseQueue : FMDatabaseQueue

/**
 *  返回唯一实例对象
 */
+ (instancetype)sharedInstance;

/**
 *  同步执行数据库操作
 *
 *  @param block  在数据库派发队列里执行的操作
 */
- (void)inDatabase:(void (^)(SSJDatabase *db))block;

/**
 *  异步执行数据库操作
 *
 *  @param block  在数据库派发队列里执行的操作
 */
- (void)asyncInDatabase:(void (^)(SSJDatabase *db))block;

/**
 *  同步执行数据库操作
 *
 *  @param block  在数据库派发队列里执行的操作
 */
- (void)inTransaction:(void (^)(SSJDatabase *db, BOOL *rollback))block;

/**
 *  异步执行数据库事务操作
 *
 *  @param block  在数据库派发队列里执行的操作
 */
- (void)asyncInTransaction:(void (^)(SSJDatabase *db, BOOL *rollback))block;

/**
 *  ？？？
 *
 *  @param block  在数据库派发队列里执行的操作
 */
- (void)inDeferredTransaction:(void (^)(SSJDatabase *db, BOOL *rollback))block;

/**
 *  ？？？
 *
 *  @param block  在数据库派发队列里执行的操作
 */
- (void)asyncInDeferredTransaction:(void (^)(SSJDatabase *db, BOOL *rollback))block;

@end
