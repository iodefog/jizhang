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

//上一次选择的资金账户类型
extern NSString *const lastSelectFundItemKey;

//  同步成功通知
extern NSString *const SSJSyncDataSuccessNotification;




