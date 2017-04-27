//
//  SSJNetworkReachabilityManager.h
//  SuiShouJi
//
//  Created by old lang on 16/6/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSJNetworkReachabilityStatus) {
    SSJNetworkReachabilityStatusUnknown          = -1,
    SSJNetworkReachabilityStatusNotReachable     = 0,
    SSJNetworkReachabilityStatusReachableViaWWAN = 1,
    SSJNetworkReachabilityStatusReachableViaWiFi = 2,
};

typedef void(^SSJNetworkReachabilityManagerBlock)(SSJNetworkReachabilityStatus status);

@class SSJNetworkReachabilityObserver;

@interface SSJNetworkReachabilityManager : NSObject

+ (void)startMonitoring;

+ (void)stopMonitoring;

+ (SSJNetworkReachabilityStatus)networkReachabilityStatus;

+ (BOOL)isReachable;

+ (SSJNetworkReachabilityObserver *)observeReachabilityStatusChange:(SSJNetworkReachabilityManagerBlock)block;

+ (void)addObserverForReachabilityStatusChange:(SSJNetworkReachabilityObserver *)observer;

+ (void)removeObserverForReachabilityStatusChange:(SSJNetworkReachabilityObserver *)observer;

@end

@interface SSJNetworkReachabilityObserver : NSObject

@property (nonatomic, copy, readonly) SSJNetworkReachabilityManagerBlock block;

- (instancetype)initWithBlock:(SSJNetworkReachabilityManagerBlock)block;

@end
