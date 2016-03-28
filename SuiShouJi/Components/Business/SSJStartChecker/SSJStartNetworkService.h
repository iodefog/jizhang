//
//  SSJStartNetworkService.h
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJStartNetworkService : SSJBaseNetworkService

//  版本描述
@property (readonly, nonatomic, copy) NSString *content;

//  App版本
@property (readonly, nonatomic, copy) NSString *appversion;

//  下载地址
@property (readonly, nonatomic, copy) NSString *url;

//  0 为普通升级 1 为强制升级
@property (readonly, nonatomic, copy) NSString *type;

//  是否正在审核
@property (readonly, nonatomic) BOOL isInReview;

//  提醒文字
@property (readonly, nonatomic, copy) NSString *remindMassage;

//  启动页图片
@property (readonly, nonatomic, copy) NSString *startImage;

- (void)request;

@end
