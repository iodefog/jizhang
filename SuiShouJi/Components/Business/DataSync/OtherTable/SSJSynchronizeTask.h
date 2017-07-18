//
//  SSJSynchronizeTask.h
//  SuiShouJi
//
//  Created by old lang on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJSyncFileModel.h"
#import "SSJGlobalServiceManager.h"

@interface SSJSynchronizeTask : NSObject

+ (instancetype)task;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, weak) dispatch_queue_t syncQueue;

@property (nonatomic, strong) SSJGlobalServiceManager *sessionManager;

/**
 *  开始数据同步，需要子类覆写，本类中什么也没做
 *
 *  @param success  同步成功回调
 *  @param failure  同步失败回调
 */
- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
