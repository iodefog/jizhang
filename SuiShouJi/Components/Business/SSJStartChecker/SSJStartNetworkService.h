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

- (void)request;

@end
