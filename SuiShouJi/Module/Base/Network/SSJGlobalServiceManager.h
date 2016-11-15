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
 *  证书验证模式；默认为AFSSLPinningModeCertificate
 *  AFSSLPinningModeNone：不验证客户端证书
 *  AFSSLPinningModePublicKey：验证客户端的证书公钥和服务端的证书公钥是否一致
 *  AFSSLPinningModeCertificate：验证客户端的证书和服务端的证书是否一致
 */
@property (nonatomic, assign) AFSSLPinningMode SSLPinningMode;

/**
 *  是否允许无效或过期的证书
 */
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/**
 *  是否开启域名验证
 */
@property (nonatomic, assign) BOOL validatesDomainName;

/**
 *  返回单列对象，此单列管理一个 url session
 */
+ (instancetype)sharedManager;

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
