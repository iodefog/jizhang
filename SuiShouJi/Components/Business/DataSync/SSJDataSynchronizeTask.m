//
//  SSJDataSynchronizeTask.m
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSynchronizeTask.h"

//  同步文件名称
static NSString *const kSyncFileName = @"sync_data.json";

//  压缩文件名称
static NSString *const kSyncZipFileName = @"sync_data.zip";

//  加密密钥字符串
static NSString *const kSignKey = @"accountbook";

@interface SSJDataSynchronizeTask ()

@end

@implementation SSJDataSynchronizeTask

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
}

@end
