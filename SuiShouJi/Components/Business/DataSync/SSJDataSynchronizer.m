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
#import "SSJSynchronizeTaskQueue.h"

@interface SSJSynchronizeBlock : NSObject

@property (nonatomic, strong) NSMutableArray *blocks;

- (void)addBlock:(nullable id)block;

- (void)removeBlock;

@end

@implementation SSJSynchronizeBlock

+ (instancetype)block {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.blocks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addBlock:(nullable id)block {
    if (!block) {
        [self.blocks addObject:[NSNull null]];
        return;
    }
    [self.blocks addObject:block];
}

- (nullable id)block {
    if ([[self.blocks firstObject] isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [self.blocks firstObject];
}

- (void)removeBlock {
    [self.blocks ssj_removeFirstObject];
}

@end

//  定时同步时间间隔
static NSTimeInterval kSyncInterval = 60 * 60;

static const void * kSSJDataSynchronizerSpecificKey = &kSSJDataSynchronizerSpecificKey;

@interface SSJDataSynchronizer () <SSJSynchronizeTaskQueueDelegate>

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) SSJSynchronizeTaskQueue *dataSyncQueue;

@property (nonatomic, strong) SSJSynchronizeTaskQueue *imageSyncQueue;

@property (nonatomic, strong) SSJSynchronizeBlock *dataSuccessBlocks;

@property (nonatomic, strong) SSJSynchronizeBlock *dataFailureBlocks;

@property (nonatomic, strong) SSJSynchronizeBlock *imageSuccessBlocks;

@property (nonatomic, strong) SSJSynchronizeBlock *imageFailureBlocks;

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
        self.dataSuccessBlocks = [[SSJSynchronizeBlock alloc] init];
        self.dataFailureBlocks = [[SSJSynchronizeBlock alloc] init];
        
        self.imageSuccessBlocks = [[SSJSynchronizeBlock alloc] init];
        self.imageFailureBlocks = [[SSJSynchronizeBlock alloc] init];
        
        self.dataSyncQueue = [[SSJSynchronizeTaskQueue alloc] initWithLabel:"com.9188.jizhang.dataSyncQueue"];
        self.dataSyncQueue.delegate = self;
        
        self.imageSyncQueue = [[SSJSynchronizeTaskQueue alloc] initWithLabel:"com.9188.jizhang.imageSyncQueue"];
        self.imageSyncQueue.delegate = self;
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
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI
        && [AFNetworkReachabilityManager managerForDomain:SSJBaseURLString].isReachable) {
        [self startSyncWithSuccess:NULL failure:NULL];
    }
}

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [self.dataSuccessBlocks addBlock:success];
    [self.dataFailureBlocks addBlock:failure];
    
    [self.imageSuccessBlocks addBlock:success];
    [self.imageFailureBlocks addBlock:failure];
    
    [self.dataSyncQueue addTask:[SSJDataSynchronizeTask task]];
    [self.imageSyncQueue addTask:[SSJImageSynchronizeTask task]];
}

#pragma mark - SSJSynchronizeTaskQueueDelegate
- (void)synchronizeTaskQueue:(SSJSynchronizeTaskQueue *)queue successToFinishTask:(SSJSynchronizeTask *)task {
    //  数据同步成功
    if (self.dataSyncQueue == queue) {
        SSJDispatch_main_async_safe(^{
            void (^success)() = [self.dataSuccessBlocks block];
            if (success) {
                success();
            }
            [self.dataSuccessBlocks removeBlock];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJSyncDataSuccessNotification object:self];
#ifdef DEBUG
            [CDAutoHideMessageHUD showMessage:@"数据同步成功"];
#endif
        });
        
        return;
    }
    
    //  图片同步成功
    if (self.imageSyncQueue == queue) {
        SSJDispatch_main_async_safe(^{
            void (^success)() = [self.imageSuccessBlocks block];
            if (success) {
                success();
            }
            [self.imageSuccessBlocks removeBlock];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJSyncImageSuccessNotification object:self];
#ifdef DEBUG
            [CDAutoHideMessageHUD showMessage:@"图片同步成功"];
#endif
        });
    }
}

- (void)synchronizeTaskQueue:(SSJSynchronizeTaskQueue *)queue failToFinishTask:(SSJSynchronizeTask *)task error:(NSError *)error {
    //  数据同步失败
    if (self.dataSyncQueue == queue) {
        SSJDispatchMainAsync(^{
            void (^failure)() = [self.dataFailureBlocks block];
            if (failure) {
                failure(error);
            }
            [self.dataFailureBlocks removeBlock];
            
#ifdef DEBUG
            [SSJAlertViewAdapter showAlertViewWithTitle:@"数据同步失败" message:error.localizedDescription action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
#endif
        });
        return;
    }
    
    //  图片同步失败
    if (self.imageSyncQueue == queue) {
        SSJDispatchMainAsync(^{
            void (^failure)() = [self.imageFailureBlocks block];
            if (failure) {
                failure(error);
            }
            [self.imageFailureBlocks removeBlock];
#ifdef DEBUG
            if (error.code == SSJErrorCodeImageSyncFailed) {
                [SSJAlertViewAdapter showAlertViewWithTitle:@"图片同步失败" message:error.localizedDescription action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
            } else if (error.code == SSJErrorCodeNoImageSyncNeedToSync) {
                [CDAutoHideMessageHUD showMessage:error.localizedDescription];
            }
#endif
        });
    }
}

@end
