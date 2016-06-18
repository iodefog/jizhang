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

@interface SSJNetworkReachabilityManager : NSObject

+ (void)startMonitoring;

+ (void)stopMonitoring;

+ (SSJNetworkReachabilityStatus)networkReachabilityStatus;

+ (BOOL)isReachable;

@end
