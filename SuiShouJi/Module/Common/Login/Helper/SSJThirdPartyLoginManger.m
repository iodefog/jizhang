//
//  SSJThirdPartyLoginManger.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThirdPartyLoginManger.h"

@implementation SSJThirdPartyLoginManger

+ (instancetype)shareInstance {
    static SSJThirdPartyLoginManger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[SSJThirdPartyLoginManger alloc] init];
        }
    });
    return instance;
}

-(SSJWeiXinLoginHelper *)weixinLogin{
    if (!_weixinLogin) {
        _weixinLogin = [[SSJWeiXinLoginHelper alloc]init];
    }
    return _weixinLogin;
}

-(SSJQQLoginHelper *)qqLogin{
    if (!_qqLogin) {
        _qqLogin = [[SSJQQLoginHelper alloc]init];
    }
    return _qqLogin;
}

@end
