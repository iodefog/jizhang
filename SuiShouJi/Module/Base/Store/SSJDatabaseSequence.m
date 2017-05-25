//
//  SSJDatabaseSequence.m
//  SuiShouJi
//
//  Created by old lang on 17/4/19.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJDatabaseSequence.h"

NSString *SSJDatabaseServiceFullName(NSString *name) {
    return [NSString stringWithFormat:@"SSJDatabaseSequence-%@", name];
};

#pragma mark - 
#pragma mark - SSJDatabaseSequenceTask

@interface SSJDatabaseSequenceTask ()

@property (nonatomic, copy) id handler;

@property (nonatomic, copy) void(^success)(id);

@property (nonatomic, copy) void(^failure)(NSError *);

@property (nonatomic) SSJDatabaseServiceTaskType type;

@property SSJDatabaseSequenceTaskState state;

@property (nonatomic, strong) NSBlockOperation *operation;

@property (nonatomic, strong) id result;

@property (nonatomic, strong) NSError *error;

@end

@implementation SSJDatabaseSequenceTask

- (void)dealloc {
    
}

+ (instancetype)taskWithHandler:(id(^)(SSJDatabase *db))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseSequenceTask *task = [[SSJDatabaseSequenceTask alloc] initWithType:SSJDatabaseServiceTaskTypeNormal handler:handler success:success failure:failure];
    return task;
}

+ (instancetype)transactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseSequenceTask *task = [[SSJDatabaseSequenceTask alloc] initWithType:SSJDatabaseServiceTaskTypeTranscation handler:handler success:success failure:failure];
    return task;
}

+ (instancetype)deferredTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseSequenceTask *task = [[SSJDatabaseSequenceTask alloc] initWithType:SSJDatabaseServiceTaskTypeDeferredTransaction handler:handler success:success failure:failure];
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
        self.state = SSJDatabaseSequenceTaskStateCanceled;
    } else if (self.operation.isFinished) {
        self.state = SSJDatabaseSequenceTaskStateFinished;
    } else if (self.operation.isExecuting) {
        self.state = SSJDatabaseSequenceTaskStateExecuting;
    } else if (self.operation.isReady) {
        self.state = SSJDatabaseSequenceTaskStatePending;
    } else {
        self.state = SSJDatabaseSequenceTaskStateUnknown;
    }
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}

@end

#pragma mark -
#pragma mark - SSJDatabaseSequence

static NSString *const kSSJDatabaseServiceLockName = @"com.ShuiShouJi.SSJDatabaseSequence.lock";

@interface SSJDatabaseSequence ()

@property (nonatomic, copy, nullable) NSString *name;

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSMutableArray<SSJDatabaseSequenceTask *> *innerTasks;

@property (nonatomic, strong) NSLock *lock;

@end

@implementation SSJDatabaseSequence

- (void)dealloc {
    
}

+ (instancetype)sequence {
    return [self sequenceWithName:nil];
}

+ (instancetype)sequenceWithName:(NSString *)name {
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

- (void)addTask:(SSJDatabaseSequenceTask *)task {
    if (!task || ![task isKindOfClass:[SSJDatabaseSequenceTask class]]) {
        return;
    }
    [self.queue addOperation:task.operation];
    
    [self.lock lock];
    [self.innerTasks addObject:task];
    [self.lock unlock];
    
    @weakify(self);
    [RACObserve(task, state) subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] == SSJDatabaseSequenceTaskStateFinished
            || [x integerValue] == SSJDatabaseSequenceTaskStateCanceled) {
            [self.lock lock];
            [self.innerTasks removeObject:task];
            [self.lock unlock];
        }
    }];
}

- (SSJDatabaseSequenceTask *)addTaskWithHandler:(id(^)(SSJDatabase *db))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseSequenceTask *task = [SSJDatabaseSequenceTask taskWithHandler:handler success:success failure:failure];
    task.identifier = SSJUUID();
    [self addTask:task];
    return task;
}

- (SSJDatabaseSequenceTask *)addTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseSequenceTask *task = [SSJDatabaseSequenceTask transactionTaskWithHandler:handler success:success failure:failure];
    task.identifier = SSJUUID();
    [self addTask:task];
    return task;
}

- (SSJDatabaseSequenceTask *)addDeferredTransactionTaskWithHandler:(id(^)(SSJDatabase *db, BOOL *rollback))handler success:(void(^)(id result))success failure:(void(^)(NSError *))failure {
    SSJDatabaseSequenceTask *task = [SSJDatabaseSequenceTask deferredTransactionTaskWithHandler:handler success:success failure:failure];
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
