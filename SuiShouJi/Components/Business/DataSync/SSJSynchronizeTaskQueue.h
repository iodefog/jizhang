//
//  SSJSynchronizeTaskQueue.h
//  SuiShouJi
//
//  Created by old lang on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJSynchronizeTask;
@class SSJSynchronizeTaskQueue;

@protocol SSJSynchronizeTaskQueueDelegate <NSObject>

//- (void)SSJSynchronizeTaskQueue:(SSJSynchronizeTaskQueue *)queue didStartTask:(SSJSynchronizeTask *)task;

- (void)synchronizeTaskQueue:(SSJSynchronizeTaskQueue *)queue successToFinishTask:(SSJSynchronizeTask *)task;

- (void)synchronizeTaskQueue:(SSJSynchronizeTaskQueue *)queue failToFinishTask:(SSJSynchronizeTask *)task error:(NSError *)error;

@end



@interface SSJSynchronizeTaskQueue : NSObject

@property (nonatomic, weak) id<SSJSynchronizeTaskQueueDelegate> delegate;

- (instancetype)initWithLabel:(const char *)label;

- (void)addTask:(SSJSynchronizeTask *)task;

@end
