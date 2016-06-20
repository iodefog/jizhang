//
//  SSJNetworkReachabilityManager.m
//  SuiShouJi
//
//  Created by old lang on 16/6/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNetworkReachabilityManager.h"
#import "AFNetworkReachabilityManager.h"

@implementation SSJNetworkReachabilityManager

//+ (void)load {
//    [self reachability];
//    NSLog(@"111");
//}

+ (AFNetworkReachabilityManager *)reachability {
    static AFNetworkReachabilityManager *reachability = nil;
    if (!reachability) {
        reachability = [AFNetworkReachabilityManager managerForDomain:@"www.baidu.com"];
    }
    return reachability;
}

+ (void)startMonitoring {
    [[self reachability] startMonitoring];
}

+ (void)stopMonitoring {
    [[self reachability] stopMonitoring];
}

+ (SSJNetworkReachabilityStatus)networkReachabilityStatus {
    switch ([self reachability].networkReachabilityStatus) {
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

+ (BOOL)isReachable {
    return [self reachability].isReachable;
}

@end
