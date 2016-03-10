//
//  SSJLoginService.h
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJUserItem.h"

typedef NS_ENUM(NSUInteger, SSJLoginType) {
    SSJLoginTypeNormal,
    SSJLoginTypeQQ
};

@interface SSJLoginService : SSJBaseNetworkService

//  登录方式
@property (readonly, nonatomic) SSJLoginType loginType;

//用户账户类型数据
@property (readonly, nonatomic,strong) NSArray *fundInfoArray;

//用户记账类型数据
@property (readonly, nonatomic,strong) NSArray *userBillArray;

//登录用户的accesstoken
@property (readonly, nonatomic,strong) NSString *accesstoken;

//登录用户的appid
@property (readonly, nonatomic,strong) NSString *appid;

@property (readonly, nonatomic,strong) SSJUserItem *item;

/**
 *  普通登录
 *
 *  @param password    用户密码
 *  @param useraccount 用户名
 */
- (void)loadLoginModelWithPassWord:(NSString*)password AndUserAccount:(NSString*)useraccount;

/**
 *  qq登录
 *
 *  @param openID    用户密码
 *  @param realName 用户名
 *  @param icon 用户名
 */
- (void)loadLoginModelWithopenID:(NSString*)openID realName:(NSString*)realName icon:(NSString*)icon;


@end
