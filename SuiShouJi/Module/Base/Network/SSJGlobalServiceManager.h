//
//  SSJGlobalServiceManager.h
//  MoneyMore
//
//  Created by old lang on 15-4-9.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "SSJBaseNetworkService.h"

@interface SSJGlobalServiceManager : AFHTTPSessionManager

/**
 *  是否开启https
 */
@property (nonatomic, assign) BOOL httpsOpened;

/**
 *  返回单列对象，此单列管理一个 url session
 */
+ (instancetype)sharedManager;

/**
 返回一个新的实例对象，此方法定义了缓存策略、证书验证方式、返回数据序列化方式

 @return
 */
+ (instancetype)standardManager;

/**
 *  如果创建一个新的请求，需要调用此方法把service添加到数组中；
 *  此方法来实现控制是否需要显示加载框
 */
+ (void)addService:(SSJBaseNetworkService *)service;

/**
 *  如果请求结束，无论是成功还是失败，都需要调用此方法把service从数组中移除；
 *  此方法来实现控制是否需要隐藏加载框
 */
+ (void)removeService:(SSJBaseNetworkService *)service;

/**
 *  重新加载SSL证书
 */
+ (void)reloadPinnedCertificates;

@end
