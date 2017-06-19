//
//  SSJDatabaseSequence.h
//  SuiShouJi
//
//  Created by old lang on 17/4/19.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJDatabaseQueue.h"

@class SSJDatabaseSequenceTask;
@class SSJDatabaseSequenceCompoundTask;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SSJDatabaseSequenceTask
#pragma mark -
@interface SSJDatabaseSequence : NSObject

/**
 队列的名字，用于调试的时候识别队列
 */
@property (nonatomic, copy, readonly, nullable) NSString *name;

/**
 当前队列中的任务，这些任务的状态只能是“等待”或者“正在执行”，“已完成”／“已取消”的任务会被移出队列
 */
@property (nonatomic, copy, readonly) NSArray<SSJDatabaseSequenceTask *> *tasks;

/**
 便捷的构造方法

 @return SSJDatabaseSequence实例
 */
+ (instancetype)sequence;

/**
 标准的构造方法

 @param name service的名称，用于调试的时候标识
 @return SSJDatabaseSequence实例
 */
+ (instancetype)sequenceWithName:(nullable NSString *)name;

/**
 向队列中添加任务，任务之间都是顺序执行，不会并发

 @param task SSJDatabaseSequenceTask实例
 */
- (void)addTask:(SSJDatabaseSequenceTask *)task;

/**
 <#Description#>

 @param compoundTask <#compoundTask description#>
 */
- (void)addCompoundTask:(SSJDatabaseSequenceCompoundTask *)compoundTask;

/**
 创建数据库任务并添加到队列中，返回任务对象，任务之间都是顺序执行，不会并发

 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return 创建的任务
 */
- (SSJDatabaseSequenceTask *)addTaskWithHandler:(id(^)(SSJDatabase *db))handler
                                       success:(void(^)(_Nullable id result))success
                                       failure:(void(^)(NSError *error))failure;
/**
 创建数据库事务任务并添加到队列中，返回任务对象，任务之间都是顺序执行，不会并发
 
 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return 创建的任务
 */
- (SSJDatabaseSequenceTask *)addTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler
                                                  success:(void(^)(_Nullable id result))success
                                                  failure:(void(^)(NSError *error))failure;
/**
 创建数据库事务任务并添加到队列中，返回任务对象，任务之间都是顺序执行，不会并发
 
 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return 创建的任务
 */
- (SSJDatabaseSequenceTask *)addDeferredTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler
                                                          success:(void(^)(_Nullable id result))success
                                                          failure:(void(^)(NSError *error))failure;

/**
 取消所有排队的任务，但无法取消正在进行中的任务
 */
- (void)cancelAllTasks;

@end

#pragma mark - SSJDatabaseSequenceTaskProtocol
#pragma mark -
/**
 数据库任务的状态
 
 - SSJDatabaseSequenceTaskStateInitial: 初始状态
 - SSJDatabaseSequenceTaskStatePending: 等待
 - SSJDatabaseSequenceTaskStateExecuting: 正在进行中
 - SSJDatabaseSequenceTaskStateFinished: 已经完成
 - SSJDatabaseSequenceTaskStateCanceled: 已经取消
 */
typedef NS_ENUM(NSInteger, SSJDatabaseSequenceTaskState) {
    SSJDatabaseSequenceTaskStatePending = 0,
    SSJDatabaseSequenceTaskStateExecuting,
    SSJDatabaseSequenceTaskStateFinished,
    SSJDatabaseSequenceTaskStateCanceled
};

@protocol SSJDatabaseSequenceTaskProtocol <NSObject>

/**
 任务的执行状态
 */
@property (readonly) SSJDatabaseSequenceTaskState state;

/**
 <#Description#>
 */
- (void)cancel;

@end

#pragma mark - SSJDatabaseSequenceTask
#pragma mark -
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

@interface SSJDatabaseSequenceTask : NSObject <SSJDatabaseSequenceTaskProtocol>

/**
 用于识别任务的标识，调试用
 */
@property (nonatomic, copy, nullable) NSString *identifier;

/**
 任务的类型
 */
@property (nonatomic, readonly) SSJDatabaseServiceTaskType type;

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
 @return SSJDatabaseSequenceTask实例
 */
+ (instancetype)taskWithHandler:(id(^)(SSJDatabase *db))handler
                        success:(void(^)(_Nullable id result))success
                        failure:(nullable void(^)(NSError *error))failure;

/**
 创建执行事务操作的任务
 
 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return SSJDatabaseSequenceTask实例
 */
+ (instancetype)transactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler
                                   success:(void(^)(_Nullable id result))success
                                   failure:(nullable void(^)(NSError *error))failure;

/**
 创建执行延迟事务操作的任务
 
 @param handler 任务要做的处理，此回调有个返回值，处理成功就返回结果对象或者nil，失败就反悔error对像
 @param success 处理成功的回调
 @param failure 处理失败的回调
 @return SSJDatabaseSequenceTask实例
 */
+ (instancetype)deferredTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler
                                           success:(void(^)(_Nullable id result))success
                                           failure:(nullable void(^)(NSError *error))failure;

@end

#pragma mark - SSJDatabaseSequenceCompoundTask
#pragma mark -

@interface SSJDatabaseSequenceCompoundTask : NSObject <SSJDatabaseSequenceTaskProtocol>

@property (nonatomic, copy, readonly) NSArray<SSJDatabaseSequenceTask *> *tasks;

+ (instancetype)taskWithTasks:(NSArray<SSJDatabaseSequenceTask *> *)tasks
                      success:(void(^)())success
                      failure:(nullable void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
