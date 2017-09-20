//
//  SSJSynchronizeTask.m
//  SuiShouJi
//
//  Created by old lang on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSynchronizeTask.h"
#import "AFNetworking.h"

@interface SSJSynchronizeTask ()

@end

@implementation SSJSynchronizeTask

+ (instancetype)task {
    return [[self alloc] init];
}

- (SSJGlobalServiceManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [SSJGlobalServiceManager standardManager];
    }
    return _sessionManager;
}

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
}


@end
