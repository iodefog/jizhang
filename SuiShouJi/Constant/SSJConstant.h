//
//  SSJConstant.h
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

///------------------------------------------
/// @name 枚举
///------------------------------------------

//  渠道号
typedef NS_ENUM(NSInteger, SSJAppSource) {
    SSJAppSourceMainAppStore = 8000,    //  苹果市场主包
    SSJAppSourceMainEnterPrise = 8001   //  企业版主包
};

//  注册、忘记密码类型
typedef NS_ENUM(NSInteger, SSJRegistAndForgetPasswordType) {
    SSJRegistAndForgetPasswordTypeRegist,           //  注册
    SSJRegistAndForgetPasswordTypeForgetPassword    //  忘记密码
};

typedef NS_ENUM(NSInteger, SSJSyncSettingType) {
    SSJSyncSettingTypeWWAN = 0,
    SSJSyncSettingTypeWIFI //
};

//  自定义错误码，从10000开始
typedef NS_ENUM(NSInteger, SSJErrorCode) {
    SSJErrorCodeUndefined = 10000,
    SSJErrorCodeDataSyncBusy = 10001,
    SSJErrorCodeDataSyncFailed = 10002,
    SSJErrorCodeImageSyncFailed = 10003,
    SSJErrorCodeNoImageSyncNeedToSync = 10004,
};

//  用户登录方式
typedef NS_ENUM(NSUInteger, SSJLoginType) {
    SSJLoginTypeNormal,
    SSJLoginTypeQQ,
    SSJLoginTypeWeiXin
};

//  收支类型
typedef NS_ENUM(NSInteger, SSJBillType) {
    SSJBillTypeUnknown = -1,  // 未知
    SSJBillTypeIncome = 0,    // 收入
    SSJBillTypePay = 1,       // 支出
    SSJBillTypeSurplus = 2    // 结余(收入＋支出)
};

///------------------------------------------
/// @name 基本数据常量
///------------------------------------------

extern const int64_t SSJDefaultSyncVersion;


///------------------------------------------
/// @name 字符串常量
///------------------------------------------

//
extern NSString *const SSJErrorDomain;

//  同步加密密钥字符串
extern NSString *const SSJSyncPrivateKey;

//  用户协议url
extern NSString *const SSJUserProtocolUrl;

//微信appid
extern NSString *const SSJWeiXinAppKey;

//微信desc
extern NSString *const SSJWeiXinDescription;

//微信secret
extern NSString *const SSJWeiXinSecret;

//qq appid
extern NSString *const SSJQQAppId;

//qq appkey
extern NSString *const SSJQQAppKey;

//阿里百川 appkey
extern NSString *const SSJYWAppKey;

//微博appkey
extern NSString *const SSJWeiBoAppKey;

//微博secret
extern NSString *const SSJWeiBoSecret;

//美恰appkey
extern NSString *const SSJMQAppKey;

//美恰secret
extern NSString *const SSJMQSecret;

//美恰默认客服组
extern NSString *const SSJMQDefualtGroupId;

//预算超支红色
extern NSString *const SSJOverrunRedColorValue;

//预算剩余绿色
extern NSString *const SSJSurplusGreenColorValue;

/** -------------------- KEY -------------------- */
//保存上次弹窗的时间
extern NSString *const SSJLastPopTimeKey;

//保存是否登录或者注册过
extern NSString *const SSJHaveLoginOrRegistKey;

//是否进入过资金账户首页
extern NSString *const SSJHaveEnterFundingHomeKey;

//用户的登录方式
extern NSString *const SSJUserLoginTypeKey;

//上一次下载的补丁的key
extern NSString *const SSJLastPatchVersionKey;

//当前使用的账本
extern NSString *const SSJCurrentBooksTypeKey;

//上一次下载的补丁的key
extern NSString *const SSJLastLoggedUserItemKey;

//  本地通知的key
extern NSString *const SSJReminderNotificationKey;


/** --------------- Notification --------------- */
//  数据同步成功通知
extern NSString *const SSJSyncDataSuccessNotification;

//  图片同步成功通知
extern NSString *const SSJSyncImageSuccessNotification;

//  登录或者注册成功通知
extern NSString *const SSJLoginOrRegisterNotification;

//  显示同步中通知
extern NSString *const SSJShowSyncLoadingNotification;

//  隐藏同步中通知
extern NSString *const SSJHideSyncLoadingNotification;

//  初始化数据库开始的通知
extern NSString *const SSJInitDatabaseDidBeginNotification;

//  初始化数据库完成的通知
extern NSString *const SSJInitDatabaseDidFinishNotification;

//  切换账本的通知
extern NSString *const SSJBooksTypeDidChangeNotification;


