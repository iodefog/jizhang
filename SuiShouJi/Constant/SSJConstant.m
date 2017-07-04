//
//  SSJConstant.m
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJConstant.h"

const int64_t SSJDefaultSyncVersion = -1;

const float SSJMaskAlpha = 0.3;

//网络请求事件间隔
const NSTimeInterval SSJRequestTimeDuration = 5;

const NSUInteger SSJAuthCodeLength = 6;

const NSUInteger SSJMobileNoLength = 11;

const NSUInteger SSJMinPasswordLength = 6;

const NSUInteger SSJMaxPasswordLength = 15;

const UIEdgeInsets UIEdgeInsetsEmpty = {CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN};

NSString *const SSJErrorDomain = @"com.9188.jizhang";

//NSString *const SSJAppStoreAddress = @"https://itunes.apple.com/us/app/li-cai-di/id1023600539?l=zh&ls=1&mt=8";

NSString *const SSJSyncPrivateKey = @"accountbook";

NSString *const SSJUserProtocolUrl = @"http://jz.youyuwo.com/protocol.html";

NSString *const SSJLastPopTimeKey = @"lastPopTimeKey";

NSString *const SSJLastSavedIdfaKey = @"lastSavedIdfaKey";

NSString *const SSJHaveLoginOrRegistKey = @"haveLoginOrRegistKey";

NSString *const SSJHaveEnterFundingHomeKey = @"haveEnterFundingHomeKey";

NSString *const SSJLastPatchVersionKey = @"lastPatchVersionKey";

NSString *const SSJCurrentBooksTypeKey = @"currentBooksTypeKey";

NSString *const SSJLastLoggedUserItemKey = @"SSJLastLoggedUserItemKey";

NSString *const SSJReminderNotificationKey = @"SSJReminderNotificationKey";

NSString *const SSJBookCategoryKey = @"SSJBookCategoryKey";

NSString *const SSJNoticeAlertKey = @"SSJNoticeAlertKey";

NSString *const SSJAnnouncementHaveReadKey = @"SSJAnnouncementHaveReadKey";

NSString *const SSJSyncDataSuccessNotification = @"SSJSyncDataSuccessNotification";

NSString *const SSJSyncDataFailureNotification = @"SSJSyncDataFailureNotification";

NSString *const SSJUserLoginTypeKey = @"SSJUserLoginTypeKey";

NSString *const SSJSyncImageSuccessNotification = @"SSJSyncImageSuccessNotification";

NSString *const SSJSyncImageFailureNotification = @"SSJSyncImageFailureNotification";

NSString *const SSJLoginOrRegisterNotification = @"SSJLoginOrRegisterNotification";

NSString *const SSJInitDatabaseDidBeginNotification = @"SSJInitDatabaseDidBeginNotification";

NSString *const SSJInitDatabaseDidFinishNotification = @"SSJInitDatabaseDidFinishNotification";

NSString *const SSJBooksTypeDidChangeNotification = @"SSJBooksTypeDidChangeNotification";

NSString *const SSJHomeContinueLoadingNotification = @"SSJHomeContinueLoadingNotification";

NSString *const SSJHomeFinishJZhangNotification = @"SSJHomeFinishJZhangNotification";

NSString *const SSJWeiXinAppKey = @"wxf77f7a5867124dfd";

NSString *const SSJWeiXinDescription = @"weixinLogin";

NSString *const SSJWeiXinSecret = @"597d6402c3cd82ff12ba0e81abd34b1a";

NSString *const SSJQQAppId = @"1105086761";

NSString *const SSJQQAppKey = @"mgRX8CiiIIrCoyu6";

NSString *const SSJYWAppKey = @"23359906";

NSString *const SSJWeiBoAppKey = @"4058368695";

NSString *const SSJWeiBoSecret = @"b0584e24371e5ad6118dfa0e3de3197c";

NSString *const SSJMQAppKey = @"afd40ae47cdf7df68551cfbb0d3676d5";

NSString *const SSJMQSecret = @"$2a$12$7aT9OEXA7uw3w/3WgmHyh.znbeVy32ncR2uVPpuVzvw/8LxXdeGYW";

NSString *const SSJMQDefualtGroupId = @"44f5ac6260d63968f8ac66104dd3acd8";

NSString *const SSJOverrunRedColorValue = @"#ff654c";

NSString *const SSJSurplusGreenColorValue = @"#0ac082";

NSString *const SSJAllBooksIds = @"all_books_ids";

NSString *const SSJAllBillTypeId = @"all";

NSString *const SSJAllMembersId = @"all_members_id";

NSString *const SSJNoticeRemindKey = @"SSJNoticeRemindKey";
