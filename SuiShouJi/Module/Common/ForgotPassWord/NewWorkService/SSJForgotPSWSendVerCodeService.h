//
//  SSJForgotPSWSendVerCodeService.h
//  YYDB
//
//  Created by cdd on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJForgotPSWSendVerCodeService : SSJBaseNetworkService

/**
 *  未登录状态忘记密码发送验证码
 *
 *  @param params 参数
 *  @param show   是否显示加载提示
 */
- (void)loadForgotPSWSendVerCodeWithParams:(NSDictionary *)params showIndicator:(BOOL)show;

@end
