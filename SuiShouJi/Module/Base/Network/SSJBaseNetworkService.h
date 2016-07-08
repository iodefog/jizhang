//
//  SSJBaseNetworkService.h
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "AFNetworking.h"

/* ---------------------------------------------------------------- */
/** 网络请求基类 **/
/* ---------------------------------------------------------------- */

typedef NS_ENUM(NSUInteger, SSJBaseNetworkServiceHttpMethod) {
    SSJBaseNetworkServiceHttpMethodPOST,
    SSJBaseNetworkServiceHttpMethodGET
};

@protocol SSJBaseNetworkServiceDelegate;

@interface SSJBaseNetworkService : NSObject {
@protected
    NSString *_returnCode;
    NSString *_desc;
    id _rootElement;
}

/**
 *  代理协议
 */
@property (nonatomic, weak, readonly) id <SSJBaseNetworkServiceDelegate> delegate;

/**
 *  请求方式，默认是POST
 */
@property (nonatomic, assign) SSJBaseNetworkServiceHttpMethod httpMethod;

/**
 *  请求超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  请求完成后收到的服务端返回的返回码，1为成功，其他均为失败
 */
@property (nonatomic, copy, readonly) NSString *returnCode;

/**
 *  请求完成后收到的服务端返回的描述
 */
@property (nonatomic, copy, readonly) NSString *desc;

/**
 *  服务端返回的数据
 */
@property (nonatomic, strong, readonly) id rootElement;

/**
 *  是否显示加载框，默认NO
 */
@property (nonatomic) BOOL showLodingIndicator;

/**
 *  是否为登录类型接口，决定是否需要传token和appid与登录相关的参数，默认为YES
 */
@property (nonatomic) BOOL isLoginService;

/**
 *  如果接口请求发生错误，是否显示错误信息，默认为YES
 */
@property (nonatomic) BOOL showMessageIfErrorOccured;

/**
 *  如果token无效，是否显示登录界面，默认为YES
 */
@property (nonatomic) BOOL showLoginControllerIfTokenInvalid;

/**
 *  是否成功加载过，不区分成功、失败
 *
 *  @return (BOOL)
 */
@property (readonly, nonatomic) BOOL isLoaded;

/**
 *  是否加载成功
 *
 *  @return (BOOL)
 */
@property (readonly, nonatomic) BOOL isLoadSuccess;

/**
 *  是否正在加载
 *
 *  @return (BOOL)
 */
@property (readonly, nonatomic) BOOL isLoading;

/**
 *  是否取消了请求
 */
@property (readonly, nonatomic) BOOL isCancelled;

/**
 *  服务器时间
 */
@property (nonatomic, strong, readonly) NSDate *serverDate;

/**
 *  证书验证模式；默认为AFSSLPinningModePublicKey
 *  AFSSLPinningModeNone：不验证客户端证书
 *  AFSSLPinningModePublicKey：验证客户端的证书公钥和服务端的证书公钥是否一致
 *  AFSSLPinningModeCertificate：验证客户端的证书和服务端的证书是否一致
 */
@property (nonatomic, assign) AFSSLPinningMode pinningMode;

/**
 *  是否允许无效或过期的证书，默认为YES
 */
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/**
 *  是否开启域名验证，默认为YES
 */
@property (nonatomic, assign) BOOL validatesDomainName;

/**
 *  初始化方法
 *
 *  @param delegate 代理协议
 *
 *  @return (instancetype)
 */
- (instancetype)initWithDelegate:(id <SSJBaseNetworkServiceDelegate>)delegate;

/**
 *  开始网络请求
 *
 *  @param url    请求的地址
 *  @param params 请求的参数
 */
- (void)request:(NSString *)urlString params:(id)params;

/**
 *  取消所有未完成的请求
 */
- (void)cancel;

/**
 *  请求完成时调用此方法，需要时子类可以重写此方法，不用调用父类方法
 *
 *  @param rootElement 请求返回的数据
 */
- (void)requestDidFinish:(id)rootElement;

/**
 *  封装参数，需要时子类可以重写此方法，但必须调用父类方法
 *
 *  @param params 存储参数的字典
 *
 *  @return 封装好的参数字典
 */
- (NSMutableDictionary *)packParameters:(NSMutableDictionary *)params;

@end

/* ---------------------------------------------------------------- */
/** 网络请求代理协议 **/
/* ---------------------------------------------------------------- */

@protocol SSJBaseNetworkServiceDelegate <NSObject>

@optional

/**
 *  网络请求已经开始，调用方法request:params:后触发
 *
 *  @param service 网络请求实例对象
 */
- (void)serverDidStart:(SSJBaseNetworkService *)service;

/**
 *  网络请求已经完成
 *
 *  @param service 网络请求实例对象
 */
- (void)serverDidFinished:(SSJBaseNetworkService *)service;

/**
 *  网络请求已经取消，由方法cancel触发
 *
 *  @param service 网络请求实例对象
 */
- (void)serverDidCancel:(SSJBaseNetworkService *)service;

/**
 *  网络请求失败
 *
 *  @param service 网络请求实例对象
 *  @param error   错误描述
 */
- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error;

@end
