//
//  SSJDatabaseService.h
//  SuiShouJi
//
//  Created by old lang on 17/4/19.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJDatabaseQueue.h"

@class SSJDatabaseServiceTask;

NS_ASSUME_NONNULL_BEGIN

@interface SSJDatabaseService : NSObject

/**
 队列的名字，用于调试的时候识别队列
 */
@property (nonatomic, copy, readonly, nullable) NSString *name;

/**
 当前队列中的任务，这些任务的状态只能是“等待”或者“正在执行”，“已完成”／“已取消”的任务会被移出队列
 */
@property (nonatomic, copy, readonly) NSArray<SSJDatabaseServiceTask *> *tasks;

/**
 便捷的构造方法

 @return SSJDatabaseService实例
 */
+ (instancetype)service;

/**
 标准的构造方法

 @param name service的名称，用于调试的时候标识
 @return SSJDatabaseService实例
 */
+ (instancetype)serviceWithName:(nullable NSString *)name;

/**
 向队列中添加任务，任务之间都是顺序执行，不会并发

 @param task SSJDatabaseServiceTask实例
 */
- (void)addTask:(SSJDatabaseServiceTask *)task;

/**
 创建数据库任务并添加到队列中，返回任务对象，任务之间都是顺序执行，不会并发

 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return 创建的任务
 */
- (SSJDatabaseServiceTask *)addTaskWithHandler:(id(^)(SSJDatabase *db))handler
                                       success:(void(^)(_Nullable id result))success
                                       failure:(void(^)(NSError *error))failure;
/**
 创建数据库事务任务并添加到队列中，返回任务对象，任务之间都是顺序执行，不会并发
 
 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return 创建的任务
 */
- (SSJDatabaseServiceTask *)addTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler
                                                  success:(void(^)(_Nullable id result))success
                                                  failure:(void(^)(NSError *error))failure;
/**
 创建数据库事务任务并添加到队列中，返回任务对象，任务之间都是顺序执行，不会并发
 
 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return 创建的任务
 */
- (SSJDatabaseServiceTask *)addDeferredTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler
                                                          success:(void(^)(_Nullable id result))success
                                                          failure:(void(^)(NSError *error))failure;

/**
 取消所有排队的任务，但无法取消正在进行中的任务
 */
- (void)cancelAllTasks;

@end


/**
 任务类型

 - SSJDatabaseServiceTaskTypeNormal: 普通
 - SSJDatabaseServiceTaskTypeTranscation: 事务
 - SSJDatabaseServiceTaskTypeDeferredTransaction: 延迟事务
 */
typedef NS_ENUM(NSInteger, SSJDatabaseServiceTaskType) {
    SSJDatabaseServiceTaskTypeNormal = 0,
    SSJDatabaseServiceTaskTypeTranscation,
    SSJDatabaseServiceTaskTypeDeferredTransaction
};

/**
 数据库任务的状态

 - SSJDatabaseServiceTaskStateUnknown: 未知
 - SSJDatabaseServiceTaskStatePending: 等待
 - SSJDatabaseServiceTaskStateExecuting: 正在进行中
 - SSJDatabaseServiceTaskStateFinished: 已经完成
 - SSJDatabaseServiceTaskStateCanceled: 已经取消
 */
typedef NS_ENUM(NSInteger, SSJDatabaseServiceTaskState) {
    SSJDatabaseServiceTaskStateUnknown = -1,
    SSJDatabaseServiceTaskStatePending = 0,
    SSJDatabaseServiceTaskStateExecuting,
    SSJDatabaseServiceTaskStateFinished,
    SSJDatabaseServiceTaskStateCanceled
};

@interface SSJDatabaseServiceTask : NSObject

/**
 用于识别任务的标识，调试用
 */
@property (nonatomic, copy, nullable) NSString *identifier;

/**
 任务的类型
 */
@property (nonatomic, readonly) SSJDatabaseServiceTaskType type;

/**
 任务的执行状态
 */
@property (readonly) SSJDatabaseServiceTaskState state;

/**
 执行任务成功后的结果
 */
@property (nonatomic, strong, readonly, nullable) id result;

/**
 执行任务失败后的错误
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/**
 创建执行普通操作的任务

 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return SSJDatabaseServiceTask实例
 */
+ (instancetype)taskWithHandler:(id(^)(SSJDatabase *db))handler
                        success:(void(^)(_Nullable id result))success
                        failure:(void(^)(NSError *error))failure;

/**
 创建执行事务操作的任务
 
 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return SSJDatabaseServiceTask实例
 */
+ (instancetype)transactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler
                                   success:(void(^)(_Nullable id result))success
                                   failure:(void(^)(NSError *error))failure;

/**
 创建执行延迟事务操作的任务
 
 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return SSJDatabaseServiceTask实例
 */
+ (instancetype)deferredTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler
                                           success:(void(^)(_Nullable id result))success
                                           failure:(void(^)(NSError *error))failure;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
