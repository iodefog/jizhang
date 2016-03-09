//
//  SSJQQLoginService.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBaseNetworkService.h"
#import "SSJUserItem.h"

@interface SSJQQLoginService : SSJBaseNetworkService

- (void)loadLoginModelWithopenID:(NSString*)openID realName:(NSString*)realName icon:(NSString*)icon;

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
