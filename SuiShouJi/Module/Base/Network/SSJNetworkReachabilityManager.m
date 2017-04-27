//
//  SSJNetworkReachabilityManager.m
//  SuiShouJi
//
//  Created by old lang on 16/6/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNetworkReachabilityManager.h"
#import "AFNetworkReachabilityManager.h"

@interface SSJNetworkReachabilityObserver ()

@property (nonatomic, copy) SSJNetworkReachabilityManagerBlock block;

@end

@implementation SSJNetworkReachabilityObserver

- (instancetype)initWithBlock:(SSJNetworkReachabilityManagerBlock)block {
    if (self = [super init]) {
        self.block = block;
    }
    return self;
}

@end

@interface SSJNetworkReachabilityManager ()

@property (nonatomic, strong) AFNetworkReachabilityManager *reachability;

@property (nonatomic, strong) NSMutableArray<SSJNetworkReachabilityObserver *> *observers;

@end

@implementation SSJNetworkReachabilityManager

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMonitoring) name:UIApplicationDidFinishLaunchingNotification object:NULL];
}

+ (SSJNetworkReachabilityManager *)sharedManager {
    static dispatch_once_t onceToken;
    static SSJNetworkReachabilityManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[SSJNetworkReachabilityManager alloc] init];
    });
    return manager;
}

+ (void)startMonitoring {
    [[self sharedManager] startMonitoring];
}

+ (void)stopMonitoring {
    [[self sharedManager] stopMonitoring];
}

+ (SSJNetworkReachabilityStatus)networkReachabilityStatus {
    return [[self sharedManager] networkReachabilityStatus];
}

+ (BOOL)isReachable {
    return [self sharedManager].isReachable;
}

+ (SSJNetworkReachabilityObserver *)observeReachabilityStatusChange:(SSJNetworkReachabilityManagerBlock)block {
    SSJNetworkReachabilityObserver *observer = [[SSJNetworkReachabilityObserver alloc] init];
    observer.block = block;
    [self addObserverForReachabilityStatusChange:observer];
    return observer;
}

+ (void)addObserverForReachabilityStatusChange:(SSJNetworkReachabilityObserver *)observer {
    if (![[self sharedManager].observers containsObject:observer]) {
        [[self sharedManager].observers addObject:observer];
    }
}

+ (void)removeObserverForReachabilityStatusChange:(SSJNetworkReachabilityObserver *)observer {
    [[self sharedManager].observers removeObject:observer];
}

- (instancetype)init {
    if (self = [super init]) {
        self.observers = [NSMutableArray array];
        self.reachability = [AFNetworkReachabilityManager managerForDomain:@"www.baidu.com"];
        __weak typeof(self) wself = self;
        [self.reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            for (SSJNetworkReachabilityObserver *observer in wself.observers) {
                observer.block([wself mapStatus:status]);
            }
        }];
    }
    return self;
}

- (void)startMonitoring {
    [[self reachability] startMonitoring];
}

- (void)stopMonitoring {
    [[self reachability] stopMonitoring];
}

- (SSJNetworkReachabilityStatus)networkReachabilityStatus {
    return [self mapStatus:[self reachability].networkReachabilityStatus];
}

- (BOOL)isReachable {
    return [self reachability].isReachable;
}

- (SSJNetworkReachabilityStatus)mapStatus:(AFNetworkReachabilityStatus)status {
    switch (status) {
        case AFNetworkReachabilityStatusUnknown:
            return SSJNetworkReachabilityStatusUnknown;
            break;
            
        case AFNetworkReachabilityStatusNotReachable:
            return SSJNetworkReachabilityStatusNotReachable;
            break;
            
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return SSJNetworkReachabilityStatusReachableViaWWAN;
            break;
            
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return SSJNetworkReachabilityStatusReachableViaWiFi;
            break;
    }
}

@end
