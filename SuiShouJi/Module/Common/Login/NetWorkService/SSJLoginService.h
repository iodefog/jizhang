//
//  SSJLoginService.h
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJUserItem.h"


@interface SSJLoginService : SSJBaseNetworkService

/**
 *  获取登录信息
 *
 *  @param password    用户密码
 *  @param useraccount 用户名
 */
- (void)loadLoginModelWithPassWord:(NSString*)password AndUserAccount:(NSString*)useraccount;


//用户账户类型数据
@property (nonatomic,strong) NSArray *fundInfoArray;

//用户记账类型数据
@property (nonatomic,strong) NSArray *userBillArray;

//登录用户的accesstoken
@property (nonatomic,strong) NSString *accesstoken;

//登录用户的appid
@property (nonatomic,strong) NSString *appid;

@property (nonatomic,strong) SSJUserItem *item;


@end
