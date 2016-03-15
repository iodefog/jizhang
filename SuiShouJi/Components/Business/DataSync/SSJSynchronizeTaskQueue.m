//
//  SSJSynchronizeTaskQueue.m
//  SuiShouJi
//
//  Created by old lang on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSynchronizeTaskQueue.h"
#import "SSJSynchronizeTask.h"

//static const void * kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;

@interface SSJSynchronizeTaskQueue ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@property (nonatomic, strong) NSMutableArray *tasks;

@property (nonatomic, strong) SSJSynchronizeTask *task;

@end

@implementation SSJSynchronizeTaskQueue

- (instancetype)initWithLabel:(const char *)label {
    if (self = [super init]) {
        self.tasks = [[NSMutableArray alloc] init];
        
        self.syncQueue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
//        dispatch_queue_set_specific(self.syncQueue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
    }
    return self;
}

- (void)addTask:(SSJSynchronizeTask *)task {
    task.userId = SSJUSERID();
    task.syncQueue = self.syncQueue;
    [self.tasks addObject:task];
    [self performTaskIfNeeded];
}

- (void)performTaskIfNeeded {
    if (self.task) {
        return;
    }
    
    self.task = [self.tasks firstObject];
    if (self.task) {
        dispatch_async(self.syncQueue, ^{
            [self.task startSyncWithSuccess:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(synchronizeTaskQueue:successToFinishTask:)]) {
                    [self.delegate synchronizeTaskQueue:self successToFinishTask:self.task];
                }
                [self.tasks removeObject:self.task];
                self.task = nil;
            } failure:^(NSError *error) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(synchronizeTaskQueue:failToFinishTask:error:)]) {
                    [self.delegate synchronizeTaskQueue:self failToFinishTask:self.task error:error];
                }
                [self.tasks removeObject:self.task];
                self.task = nil;
            }];
        });
    }
}

@end
