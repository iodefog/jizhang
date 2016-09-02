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

NSString *const SSJImageBaseUrlString = @"http://account.gs.9188.com/";   // 测试环境
//NSString *const SSJImageBaseUrlString = @"http://jz.918`-8.com";

#else
NSString *const SSJBaseURLString = @"http://192.168.1.155:9008";   // 测试环境
NSString *const SSJImageBaseUrlString = @"http://account.gs.9188.com/";

//NSString *const SSJBaseURLString = @"http://jz.9188.com";
//NSString *const SSJImageBaseUrlString = @"http://jz.9188.com";
#endif

NSString *const SSJErrorDomain = @"com.9188.jizhang";

//NSString *const SSJAppStoreAddress = @"https://itunes.apple.com/us/app/li-cai-di/id1023600539?l=zh&ls=1&mt=8";

NSString *const SSJSyncPrivateKey = @"accountbook";

NSString *const SSJUserProtocolUrl = @"http://1.9188.com/h5/about_shq/protocol.html";

NSString *const SSJLastPopTimeKey = @"lastPopTimeKey";

NSString *const SSJHaveLoginOrRegistKey = @"haveLoginOrRegistKey";

NSString *const SSJHaveEnterFundingHomeKey = @"haveEnterFundingHomeKey";

NSString *const SSJLastPatchVersionKey = @"lastPatchVersionKey";

NSString *const SSJCurrentBooksTypeKey = @"currentBooksTypeKey";

NSString *const SSJLastLoggedUserItemKey = @"SSJLastLoggedUserItemKey";


NSString *const SSJSyncDataSuccessNotification = @"SSJSyncDataSuccessNotification";

NSString *const SSJUserLoginTypeKey = @"SSJUserLoginTypeKey";

NSString *const SSJSyncImageSuccessNotification = @"SSJSyncImageSuccessNotification";

NSString *const SSJLoginOrRegisterNotification = @"SSJLoginOrRegisterNotification";

NSString *const SSJShowSyncLoadingNotification = @"SSJShowSyncLoadingNotification";

NSString *const SSJHideSyncLoadingNotification = @"SSJHideSyncLoadingNotification";

NSString *const SSJReminderNotificationKey = @"SSJReminderNotificationKey";

NSString *const SSJInitDatabaseDidBeginNotification = @"SSJInitDatabaseDidBeginNotification";

NSString *const SSJInitDatabaseDidFinishNotification = @"SSJInitDatabaseDidFinishNotification";

NSString *const SSJBooksTypeDidChangeNotification = @"SSJBooksTypeDidChangeNotification";

NSString *const SSJWeiXinAppKey = @"wxf77f7a5867124dfd";

NSString *const SSJWeiXinDescription = @"weixinLogin";

NSString *const SSJWeiXinSecret = @"597d6402c3cd82ff12ba0e81abd34b1a";

NSString *const SSJQQAppId = @"1105086761";

NSString *const SSJQQAppKey = @"mgRX8CiiIIrCoyu6";

NSString *const SSJYWAppKey = @"23359906";

NSString *const SSJWeiBoAppKey = @"4058368695";

NSString *const SSJWeiBoSecret = @"b0584e24371e5ad6118dfa0e3de3197c";

