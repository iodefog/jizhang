//
//  SSJDataSynchronizer.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSynchronizer.h"
#import "AFNetworking.h"
#import "SSJDataSynchronizeTask.h"
#import "SSJImageSynchronizeTask.h"
#import "SSJDataSyncHelper.h"

//  定时同步时间间隔
static NSTimeInterval kSyncInterval = 60 * 60;

static const void * kSSJDataSynchronizerSpecificKey = &kSSJDataSynchronizerSpecificKey;

@interface SSJDataSynchronizer ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *userIdsForSyncData;

@property (nonatomic, strong) NSMutableArray *userIdsForSyncImage;

@property (nonatomic, strong) SSJDataSynchronizeTask *dataSyncTask;

@property (nonatomic, strong) SSJImageSynchronizeTask *imageSyncTask;

@end

@implementation SSJDataSynchronizer

+ (instancetype)shareInstance {
    static SSJDataSynchronizer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[SSJDataSynchronizer alloc] init];
        }
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.userIdsForSyncData = [NSMutableArray array];
        self.userIdsForSyncImage = [NSMutableArray array];
        self.syncQueue = dispatch_queue_create("com.ShuiShouJi.SSJDataSync", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(self.syncQueue, kSSJDataSynchronizerSpecificKey, (__bridge void *)self, NULL);
    }
    return self;
}

- (void)startTimingSync {
    if (!self.timer) {
        self.timer = [NSTimer timerWithTimeInterval:kSyncInterval target:self selector:@selector(timingSyncData) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimingSync {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timingSyncData {
    if ([AFNetworkReachabilityManager managerForDomain:SSJBaseURLString].reachableViaWWAN
        || [AFNetworkReachabilityManager managerForDomain:SSJBaseURLString].reachableViaWiFi) {
        [self startSyncWithSuccess:NULL failure:NULL];
    }
}

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    //  开始同步前保存当前的用户id，防止同步过程中userid被修改导致同步数据错乱
    [self.userIdsForSyncData addObject:SSJUSERID()];
    [self.userIdsForSyncImage addObject:SSJUSERID()];
    
    SSJDataSynchronizer *currentSynchronizer = (__bridge id)dispatch_get_specific(kSSJDataSynchronizerSpecificKey);
    if (currentSynchronizer == self) {
        [self startSyncDataWithSuccessIfNeeded:success failure:failure];
        [self startSyncImageWithSuccessIfNeeded:success failure:failure];
    } else {
        dispatch_async(self.syncQueue, ^{
            [self startSyncDataWithSuccessIfNeeded:success failure:failure];
            [self startSyncImageWithSuccessIfNeeded:success failure:failure];
        });
    }
}

- (void)startSyncDataWithSuccessIfNeeded:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    if (self.userIdsForSyncData.count == 0) {
        return;
    }
    
    if (self.dataSyncTask) {
        return;
    }
    
    SSJSetCurrentSyncDataUserId([self.userIdsForSyncData firstObject]);
    
    self.dataSyncTask = [[SSJDataSynchronizeTask alloc] init];
    self.dataSyncTask.syncQueue = self.syncQueue;
    [self.dataSyncTask startSyncWithSuccess:^{
        
        SSJDispatch_main_async_safe(^{
            if (success) {
                success();
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJSyncDataSuccessNotification object:self];
#ifdef DEBUG
            [CDAutoHideMessageHUD showMessage:@"数据同步成功"];
#endif
        });
        
        self.dataSyncTask = nil;
        [self.userIdsForSyncData removeObjectAtIndex:0];
        [self startSyncDataWithSuccessIfNeeded:success failure:failure];
    } failure:^(NSError *error) {
        
        SSJDispatch_main_async_safe(^{
            if (failure) {
                failure(error);
            }
#ifdef DEBUG
            [CDAutoHideMessageHUD showMessage:@"数据同步失败"];
#endif
        });
        
        self.dataSyncTask = nil;
        [self.userIdsForSyncData removeObjectAtIndex:0];
        [self startSyncDataWithSuccessIfNeeded:success failure:failure];
    }];
}

- (void)startSyncImageWithSuccessIfNeeded:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    if (self.userIdsForSyncImage.count == 0) {
        return;
    }
    
    if (self.imageSyncTask) {
        return;
    }
    
    SSJSetCurrentSyncImageUserId([self.userIdsForSyncImage firstObject]);
    
    self.imageSyncTask = [[SSJImageSynchronizeTask alloc] init];
    self.imageSyncTask.syncQueue = self.syncQueue;
    [self.imageSyncTask startSyncWithSuccess:^{
        
        SSJDispatch_main_async_safe(^{
            if (success) {
                success();
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJSyncImageSuccessNotification object:self];
#ifdef DEBUG
            [CDAutoHideMessageHUD showMessage:@"图片同步成功"];
#endif
        });
        
        self.imageSyncTask = nil;
        [self.userIdsForSyncImage removeObjectAtIndex:0];
        [self startSyncImageWithSuccessIfNeeded:success failure:failure];
    } failure:^(NSError *error) {
        
        SSJDispatch_main_async_safe(^{
            if (failure) {
                failure(error);
            }
#ifdef DEBUG
            [CDAutoHideMessageHUD showMessage:@"图片同步失败"];
#endif
        });
        
        self.imageSyncTask = nil;
        [self startSyncImageWithSuccessIfNeeded:success failure:failure];
    }];
}

@end
