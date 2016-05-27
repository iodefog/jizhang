//
//  SSJLoginService.h
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJUserItem.h"

@interface SSJLoginService : SSJBaseNetworkService

//  登录方式
@property (readonly, nonatomic) SSJLoginType loginType;

//用户账户类型数据
@property (readonly, nonatomic,strong) NSArray *fundInfoArray;

//用户记账类型数据
@property (readonly, nonatomic,strong) NSArray *userBillArray;

//用户账本类型数据
@property (readonly, nonatomic,strong) NSArray *booksTypeArray;


//登录用户的accesstoken
@property (readonly, nonatomic,strong) NSString *accesstoken;

//登录用户的appid
@property (readonly, nonatomic,strong) NSString *appid;

@property (readonly, nonatomic,strong) SSJUserItem *item;

@property (readonly, nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

/**
 *  普通登录
 *
 *  @param password    用户密码
 *  @param useraccount 用户名
 */
- (void)loadLoginModelWithPassWord:(NSString*)password AndUserAccount:(NSString*)useraccount;

/**
 *  三方登录
 *
 *  @param openID    用户密码
 *  @param openID    用户密码
 *  @param realName 用户名
 *  @param icon 用户名
 */
- (void)loadLoginModelWithLoginType:(SSJLoginType)loginType openID:(NSString*)openID realName:(NSString*)realName icon:(NSString*)icon;


@end
