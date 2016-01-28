//
//  SSJConstant.m
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJConstant.h"

const int64_t SSJDefaultSyncVersion = -1;

//  接口域名
#ifdef DEBUG
//NSString *const SSJBaseURLString = @"http://192.168.2.47:8080";  // 东亚
//NSString *const SSJBaseURLString = @"http://192.168.1.155:8091";
NSString *const SSJBaseURLString = @"http://192.168.1.155:9008";   // 测试环境
//NSString *const SSJBaseURLString = @"http://1.9188.com";
#else
NSString *const SSJBaseURLString = @"http://1.9188.com";
#endif

NSString *const SSJErrorDomain = @"com.9188.jizhang";

NSString *const lastSelectFundItemKey = @"lastSelectFundKey";

<<<<<<< HEAD
NSString *const lastPopTimeKey = @"lastPopTimeKey";

NSString *const haveLoginOrRegistKey = @"haveLoginOrRegistKey";
=======
NSString *const SSJSyncDataSuccessNotification = @"SSJSyncDataSuccessNotification";

>>>>>>> ed650f6f4ea4ccf0d659326140891af1f0e42c72
