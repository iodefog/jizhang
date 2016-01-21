//
//  SSJConstant.h
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

//___________________________________________________________________
//** 枚举 **//

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

typedef NS_ENUM(NSInteger, SSJErrorCode) {
    SSJErrorCodeUndefined = -1
};

//___________________________________________________________________

extern const int64_t SSJDefaultSyncVersion;

//___________________________________________________________________
//** 字符串常量 **//

//  接口地址
extern NSString *const SSJBaseURLString;

//
extern NSString *const SSJErrorDomain;





