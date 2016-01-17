//
//  SSJForgotPSWCheckVerCodeService.h
//  YYDB
//
//  Created by cdd on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJForgotPSWCheckVerCodeService : SSJBaseNetworkService

/**
 *  忘记密码校验验证码
 *
 *  @param params 参数
 *  @param show   显示网络指示器
 */
- (void)loadForgotPSWCheckVerCodeWithParams:(NSDictionary *)params ShowIndicator:(BOOL)show;


@end
