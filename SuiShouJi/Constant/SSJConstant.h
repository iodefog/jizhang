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
    SSJErrorCodeDataSyncBusy = 10001
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

//
extern NSString *const SSJErrorDomain;

//  appstore地址
extern NSString *const SSJAppStoreAddress;

/** -------------------- KEY -------------------- */
//上一次选择的资金账户类型
extern NSString *const SSJLastSelectFundItemKey;

//保存上次弹窗的时间
extern NSString *const SSJLastPopTimeKey;

//保存是否登录或者注册过
extern NSString *const SSJHaveLoginOrRegistKey;

//是否进入过资金账户首页
extern NSString *const SSJHaveEnterFundingHomeKey;

/** --------------- Notification --------------- */
//  同步成功通知
extern NSString *const SSJSyncDataSuccessNotification;

//  登录或者注册成功通知
extern NSString *const SSJLoginOrRegisterNotification;

//  显示同步中通知
extern NSString *const SSJShowSyncLoadingNotification;

//  隐藏同步中通知
extern NSString *const SSJHideSyncLoadingNotification;

