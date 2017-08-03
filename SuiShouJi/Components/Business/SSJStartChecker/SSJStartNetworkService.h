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

//  是否正在审核，默认YES
@property (readonly, nonatomic) BOOL isInReview;

//  提醒文字
@property (readonly, nonatomic, copy) NSString *remindMassage;

//  启动页图片
//@property (readonly, nonatomic, copy) NSString *startImage;
//
////  lottie的地址
//@property (readonly, nonatomic, copy) NSString *lottieUrl;
//
////  动态的动画
//@property (readonly, nonatomic, copy) NSString *animImage;

//  美恰的用户组
@property (readonly, nonatomic, copy) NSString *mqGroupId;

//  客服电话
@property (readonly, nonatomic, copy) NSString *serviceNumber;

- (void)request;

@end
