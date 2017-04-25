//
//  SSJDatabaseService.m
//  SuiShouJi
//
//  Created by old lang on 17/4/19.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJDatabaseService.h"

NSString *SSJDatabaseServiceFullName(NSString *name) {
    return [NSString stringWithFormat:@"SSJDatabaseService-%@", name];
};

#pragma mark - 
#pragma mark - SSJDatabaseServiceTask

@interface SSJDatabaseServiceTask ()

@property (nonatomic, copy) id handler;

@property (nonatomic, copy) void(^success)(id);

@property (nonatomic, copy) void(^failure)(NSError *);

@property (nonatomic) SSJDatabaseServiceTaskType type;

@property SSJDatabaseServiceTaskState state;

@property (nonatomic, strong) NSBlockOperation *operation;

@property (nonatomic, strong) id result;

@property (nonatomic, strong) NSError *error;

@end

@implementation SSJDatabaseServiceTask

- (void)dealloc {
    
}

+ (instancetype)taskWithHandler:(id(^)(SSJDatabase *db))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseServiceTask *task = [[SSJDatabaseServiceTask alloc] initWithType:SSJDatabaseServiceTaskTypeNormal handler:handler success:success failure:failure];
    return task;
}

+ (instancetype)transactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseServiceTask *task = [[SSJDatabaseServiceTask alloc] initWithType:SSJDatabaseServiceTaskTypeTranscation handler:handler success:success failure:failure];
    return task;
}

+ (instancetype)deferredTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseServiceTask *task = [[SSJDatabaseServiceTask alloc] initWithType:SSJDatabaseServiceTaskTypeDeferredTransaction handler:handler success:success failure:failure];
    return task;
}

- (instancetype)initWithType:(SSJDatabaseServiceTaskType)type handler:(id)handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    if (self = [super init]) {
        self.type = type;
        self.handler = handler;
        self.success = success;
        self.failure = failure;
        self.operation = [self createOperation];
        [self observeOperationState];
        @weakify(self);
        self.operation.completionBlock = ^{
            @strongify(self);
            if (self.operation.isCancelled) {
                return;
            }
            if ([self.result isKindOfClass:[NSError class]]) {
                self.failure(self.error);
            } else {
                self.success(self.result);
            }
        };
    }
    return self;
}

- (void)setIdentifier:(NSString *)identifier {
    _identifier = identifier;
    self.operation.name = SSJDatabaseServiceFullName(identifier);
}

- (void)cancel {
    [self.operation cancel];
}

- (NSBlockOperation *)createOperation {
    return [NSBlockOperation blockOperationWithBlock:^{
        switch (self.type) {
            case SSJDatabaseServiceTaskTypeNormal: {
                [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
                    id (^handler)(SSJDatabase *db) = self.handler;
                    id result = handler(db);
                    if ([result isKindOfClass:[NSError class]]) {
                        self.error = result;
                    } else {
                        self.result = result;
                    }
                }];
            }
                break;
                
            case SSJDatabaseServiceTaskTypeTranscation: {
                [[SSJDatabaseQueue sharedInstance] inTransaction:^(SSJDatabase *db, BOOL *rollback) {
                    id (^handler)(SSJDatabase *db, BOOL *rollback) = self.handler;
                    id result = handler(db, rollback);
                    if ([result isKindOfClass:[NSError class]]) {
                        self.error = result;
                    } else {
                        self.result = result;
                    }
                }];
            }
                break;
                
            case SSJDatabaseServiceTaskTypeDeferredTransaction: {
                [[SSJDatabaseQueue sharedInstance] inDeferredTransaction:^(SSJDatabase *db, BOOL *rollback) {
                    id (^handler)(SSJDatabase *db, BOOL *rollback) = self.handler;
                    id result = handler(db, rollback);
                    if ([result isKindOfClass:[NSError class]]) {
                        self.error = result;
                    } else {
                        self.result = result;
                    }
                }];
            }
                break;
        }
    }];
}

- (void)observeOperationState {
    RACSignal *sg1 = RACObserve(self.operation, isReady);
    RACSignal *sg2 = RACObserve(self.operation, isExecuting);
    RACSignal *sg3 = RACObserve(self.operation, isFinished);
    RACSignal *sg4 = RACObserve(self.operation, isCancelled);
    @weakify(self);
    [[RACSignal merge:@[sg1, sg2, sg3, sg4]] subscribeNext:^(id x) {
        @strongify(self);
        [self updateState];
    }];
}

- (void)updateState {
    if (self.operation.isCancelled) {
        self.state = SSJDatabaseServiceTaskStateCanceled;
    } else if (self.operation.isFinished) {
        self.state = SSJDatabaseServiceTaskStateFinished;
    } else if (self.operation.isExecuting) {
        self.state = SSJDatabaseServiceTaskStateExecuting;
    } else if (self.operation.isReady) {
        self.state = SSJDatabaseServiceTaskStatePending;
    } else {
        self.state = SSJDatabaseServiceTaskStateUnknown;
    }
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}

@end

#pragma mark -
#pragma mark - SSJDatabaseService

static NSString *const kSSJDatabaseServiceLockName = @"com.ShuiShouJi.SSJDatabaseService.lock";

@interface SSJDatabaseService ()

@property (nonatomic, copy, nullable) NSString *name;

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSMutableArray<SSJDatabaseServiceTask *> *innerTasks;

@property (nonatomic, strong) NSLock *lock;

@end

@implementation SSJDatabaseService

- (void)dealloc {
    
}

+ (instancetype)service {
    return [self serviceWithName:nil];
}

+ (instancetype)serviceWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.name = name;
        self.innerTasks = [NSMutableArray array];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.name = SSJDatabaseServiceFullName(name);
        self.queue.maxConcurrentOperationCount = 1;
        self.lock = [[NSLock alloc] init];
        self.lock.name = kSSJDatabaseServiceLockName;
    }
    return self;
}

- (NSArray *)tasks {
    return [self.innerTasks copy];
}

- (void)addTask:(SSJDatabaseServiceTask *)task {
    if (!task || ![task isKindOfClass:[SSJDatabaseServiceTask class]]) {
        return;
    }
    [self.queue addOperation:task.operation];
    
    [self.lock lock];
    [self.innerTasks addObject:task];
    [self.lock unlock];
    
    @weakify(self);
    [RACObserve(task, state) subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] == SSJDatabaseServiceTaskStateFinished
            || [x integerValue] == SSJDatabaseServiceTaskStateCanceled) {
            [self.lock lock];
            [self.innerTasks removeObject:task];
            [self.lock unlock];
        }
    }];
}

- (SSJDatabaseServiceTask *)addTaskWithHandler:(id(^)(SSJDatabase *db))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseServiceTask *task = [SSJDatabaseServiceTask taskWithHandler:handler success:success failure:failure];
    task.identifier = SSJUUID();
    [self addTask:task];
    return task;
}

- (SSJDatabaseServiceTask *)addTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseServiceTask *task = [SSJDatabaseServiceTask transactionTaskWithHandler:handler success:success failure:failure];
    task.identifier = SSJUUID();
    [self addTask:task];
    return task;
}

- (SSJDatabaseServiceTask *)addDeferredTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseServiceTask *task = [SSJDatabaseServiceTask deferredTransactionTaskWithHandler:handler success:success failure:failure];
    task.identifier = SSJUUID();
    [self addTask:task];
    return task;
}

- (void)cancelAllTasks {
    [self.queue cancelAllOperations];
    [self.lock lock];
    [self.innerTasks removeAllObjects];
    [self.lock unlock];
}

@end
