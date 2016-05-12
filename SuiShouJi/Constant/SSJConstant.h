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
    SSJSyncSettingTypeWIFI, //
    SSJSyncSettingTypeWWAN  //
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

///------------------------------------------
/// @name 基本数据常量
///------------------------------------------

extern const int64_t SSJDefaultSyncVersion;


///------------------------------------------
/// @name 字符串常量
///------------------------------------------

//  接口地址
extern NSString *const SSJBaseURLString;

//  图片域名
extern NSString *const SSJImageBaseUrlString;

//
extern NSString *const SSJErrorDomain;

//  appstore地址
extern NSString *const SSJAppStoreAddress;

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

//qq appkey
extern NSString *const SSJQQAppKey;

//阿里百川 appkey
extern NSString *const SSJYWAppKey;

/** -------------------- KEY -------------------- */
//上一次选择的资金账户类型
extern NSString *const SSJLastSelectFundItemKey;

//保存上次弹窗的时间
extern NSString *const SSJLastPopTimeKey;

//保存是否登录或者注册过
extern NSString *const SSJHaveLoginOrRegistKey;

//是否进入过资金账户首页
extern NSString *const SSJHaveEnterFundingHomeKey;

//用户的登录方式
extern NSString *const SSJUserLoginTypeKey;


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

//  记账提醒的通知
extern NSString *const SSJChargeReminderNotification;

//  初始化数据库开始的通知
extern NSString *const SSJInitDatabaseDidBeginNotification;

//  初始化数据库完成的通知
extern NSString *const SSJInitDatabaseDidFinishNotification;


