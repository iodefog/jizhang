//
//  SSJDatabaseQueue.h
//  SuiShouJi
//
//  Created by old lang on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <FMDB/FMDB.h>

@interface SSJDatabaseQueue : FMDatabaseQueue

/**
 *  返回唯一实例对象
 */
+ (instancetype)sharedInstance;

/**
 *  异步执行数据库操作
 *
 *  @param block  在数据库派发队列里执行的操作
 */
- (void)asyncInDatabase:(void (^)(FMDatabase *db))block;

/**
 *  异步执行数据库事务操作
 *
 *  @param block  在数据库派发队列里执行的操作
 */
- (void)asyncInTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

/**
 *  ？？？
 *
 *  @param block  在数据库派发队列里执行的操作
 */
- (void)asyncInDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

@end
