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
#import "SSJNetworkReachabilityManager.h"
#import "SSJLoginVerifyPhoneViewController+SSJLoginCategory.h"
#import "SSJDomainManager.h"
#import "SSJShareBooksMemberKickedOutAlerter.h"
#import "SSJSyncTable.h"

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

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *userInfo;

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
        self.userInfo = [NSMutableDictionary dictionary];
        
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
    if (SSJIsUserLogined()
        && SSJSyncSetting() == SSJSyncSettingTypeWIFI
        && [AFNetworkReachabilityManager managerForDomain:[SSJDomainManager domain]].isReachable) {
        [self startSyncWithSuccess:NULL failure:NULL];
    }
}

- (void)startSyncWithSuccess:(void (^)(SSJDataSynchronizeType type))success failure:(void (^)(SSJDataSynchronizeType type, NSError *error))failure {
    
    if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusNotReachable) {
        if (failure) {
            failure(0, nil);
        }
        return;
    }
    
    [self.dataSuccessBlocks addBlock:success];
    [self.dataFailureBlocks addBlock:failure];
    
    [self.imageSuccessBlocks addBlock:success];
    [self.imageFailureBlocks addBlock:failure];
    
    [self.dataSyncQueue addTask:[SSJDataSynchronizeTask task]];
    [self.imageSyncQueue addTask:[SSJImageSynchronizeTask task]];
}

- (void)startSyncIfNeededWithSuccess:(void (^)(SSJDataSynchronizeType type))success failure:(void (^)(SSJDataSynchronizeType type, NSError *error))failure {
    
    if (!SSJIsUserLogined()) {
        return;
    }
    
    switch (SSJSyncSetting()) {
        case SSJSyncSettingTypeWIFI:
            if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusReachableViaWiFi) {
                [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:success failure:failure];
            }
            break;
            
        case SSJSyncSettingTypeWWAN:
            if ([SSJNetworkReachabilityManager isReachable]) {
                [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:success failure:failure];
            }
            break;
    }
}

#pragma mark - SSJSynchronizeTaskQueueDelegate
- (void)synchronizeTaskQueue:(SSJSynchronizeTaskQueue *)queue successToFinishTask:(SSJSynchronizeTask *)task {
    //  数据同步成功
    if (self.dataSyncQueue == queue) {
        SSJDispatchMainAsync(^{
            void (^success)() = [self.dataSuccessBlocks block];
            if (success) {
                success(SSJDataSynchronizeTypeData);
            }
            [self.dataSuccessBlocks removeBlock];
            [self.dataFailureBlocks removeBlock];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJSyncDataSuccessNotification object:self];
            [[SSJShareBooksMemberKickedOutAlerter alerter] showAlertIfNeededWithMemberId:task.userId];
#ifdef DEBUG
            [CDAutoHideMessageHUD showMessage:@"数据同步成功"];
#endif
        });
        
        return;
    }
    
    //  图片同步成功
    if (self.imageSyncQueue == queue) {
        SSJDispatchMainAsync(^{
            void (^success)() = [self.imageSuccessBlocks block];
            if (success) {
                success(SSJDataSynchronizeTypeImage);
            }
            [self.imageSuccessBlocks removeBlock];
            [self.imageFailureBlocks removeBlock];
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
            BOOL shouldPerformFailuer = YES;
            if (error.code == -5555) {
                // -5555是用户格式化后原userid被注销了，需要用户重新登陆获取新的userid
                [SSJAlertViewAdapter showAlertViewWithTitle:nil message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                    [SSJLoginVerifyPhoneViewController reloginIfNeeded];
                }], nil];
            } else if (error.code == -2000) {
                // 例如同步一条流水失败，可能是流水依赖的资金账户或者收支类别没有同步给服务端，这种情况就会导致－2000
                // 出现这类情况要清空当前用户的同步记录，然后将所有数据都同步到服务端
                // 为了防止死循环，只做一次处理
                BOOL hasResync = [self.userInfo[task.userId] boolValue];
                if (!hasResync) {
                    shouldPerformFailuer = NO;
                    self.userInfo[task.userId] = @(YES);
                    [SSJSyncTable clearSyncRecordsWithUserId:task.userId];
                    void (^success)() = [self.dataSuccessBlocks block];
                    void (^failure)() = [self.dataFailureBlocks block];
                    [self startSyncWithSuccess:success failure:failure];
                }
            } else {
                [CDAutoHideMessageHUD showError:error];
                [SSJAnaliyticsManager event:@"sync_failed" extra:error.localizedDescription];
            }
            
            if (shouldPerformFailuer) {
                void (^failure)() = [self.dataFailureBlocks block];
                if (failure) {
                    failure(SSJDataSynchronizeTypeData, error);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:SSJSyncDataFailureNotification object:self];
            }
            
            [self.dataFailureBlocks removeBlock];
            [self.dataSuccessBlocks removeBlock];
        });
        return;
    }
    
    //  图片同步失败
    if (self.imageSyncQueue == queue) {
        SSJDispatchMainAsync(^{
            void (^failure)() = [self.imageFailureBlocks block];
            if (failure) {
                failure(SSJDataSynchronizeTypeImage, error);
            }
            [self.imageFailureBlocks removeBlock];
            [self.imageSuccessBlocks removeBlock];
            
            [CDAutoHideMessageHUD showError:error];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJSyncImageFailureNotification object:self];
        });
    }
}

@end
