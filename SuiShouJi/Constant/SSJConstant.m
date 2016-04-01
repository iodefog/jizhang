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
NSString *const SSJBaseURLString = @"http://192.168.1.155:9008";   // 测试环境
//NSString *const SSJBaseURLString = @"http://jz.9188.com";

NSString *const SSJImageBaseUrlString = @"http://account.gs.9188.com/";
//NSString *const SSJImageBaseUrlString = @"http://jz.9188.com";

#else
NSString *const SSJBaseURLString = @"http://jz.9188.com";
NSString *const SSJImageBaseUrlString = @"http://jz.9188.com";
#endif

NSString *const SSJErrorDomain = @"com.9188.jizhang";

NSString *const SSJAppStoreAddress = @"https://itunes.apple.com/cn/app/9188ji-zhang/id1080564439?mt=8";

//NSString *const SSJAppStoreAddress = @"https://itunes.apple.com/us/app/li-cai-di/id1023600539?l=zh&ls=1&mt=8";

NSString *const SSJSyncPrivateKey = @"accountbook";

NSString *const SSJUserProtocolUrl = @"http://1.9188.com/h5/about_shq/protocol.html";

NSString *const SSJLastSelectFundItemKey = @"lastSelectFundKey";

NSString *const SSJLastPopTimeKey = @"lastPopTimeKey";

NSString *const SSJHaveLoginOrRegistKey = @"haveLoginOrRegistKey";

NSString *const SSJHaveEnterFundingHomeKey = @"haveEnterFundingHomeKey";

NSString *const SSJSyncDataSuccessNotification = @"SSJSyncDataSuccessNotification";

NSString *const SSJSyncImageSuccessNotification = @"SSJSyncImageSuccessNotification";

NSString *const SSJLoginOrRegisterNotification = @"SSJLoginOrRegisterNotification";

NSString *const SSJShowSyncLoadingNotification = @"SSJShowSyncLoadingNotification";

NSString *const SSJHideSyncLoadingNotification = @"SSJHideSyncLoadingNotification";

NSString *const SSJChargeReminderNotification = @"SSJChargeReminderNotification";

NSString *const SSJInitDatabaseDidBeginNotification = @"SSJInitDatabaseDidBeginNotification";

NSString *const SSJInitDatabaseDidFinishNotification = @"SSJInitDatabaseDidFinishNotification";

