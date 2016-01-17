//
//  SSJLoginService.h
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJLoginService : SSJBaseNetworkService

/**
 *  获取登录信息
 *
 *  @param password    用户密码
 *  @param useraccount 用户名
 */
- (void)loadLoginModelWithPassWord:(NSString*)password AndUserAccount:(NSString*)useraccount;

@end
