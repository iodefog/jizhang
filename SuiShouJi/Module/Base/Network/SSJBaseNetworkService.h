//
//  SSJBaseNetworkService.h
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

/* ---------------------------------------------------------------- */
/** 网络请求基类 **/
/* ---------------------------------------------------------------- */

typedef NS_ENUM(NSUInteger, SSJBaseNetworkServiceHttpMethod) {
    SSJBaseNetworkServiceHttpMethodPOST,
    SSJBaseNetworkServiceHttpMethodGET
};

typedef NS_ENUM(NSInteger, SSJRequestSerialization) {
    SSJHTTPRequestSerialization = 0,
    SSJJSONRequestSerialization,
    SSJPropertyListRequestSerialization
};

typedef NS_OPTIONS(NSInteger, SSJResponseSerialization) {
    SSJHTTPResponseSerialization = 0,
    SSJJSONResponseSerialization = 1 << 0,
    SSJXMLParserResponseSerialization = 1 << 1,
    SSJPropertyListResponseSerialization = 1 << 2,
    SSJImageResponseSerialization = 1 << 3
};

@class SSJBaseNetworkService;
typedef void(^SSJNetworkServiceHandler)(SSJBaseNetworkService *service);

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
@property (nonatomic, weak, readonly, nullable) id <SSJBaseNetworkServiceDelegate> delegate;

/**
 *  请求方式，默认是POST
 */
@property (nonatomic, assign) SSJBaseNetworkServiceHttpMethod httpMethod;

/**
 请求数据序列化方式，默认SSJHTTPRequestSerialization
 */
@property (nonatomic, assign) SSJRequestSerialization requestSerialization;

/**
 返回数据序列化方式，默认SSJJSONResponseSerialization
 */
@property (nonatomic, assign) SSJResponseSerialization responseSerialization;

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
 *  如果接口请求发生错误，是否显示错误信息，默认为YES
 */
@property (nonatomic) BOOL showMessageIfErrorOccured;

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
 *  是否开启https
 */
@property (nonatomic, assign) BOOL httpsOpened;

/**
 *  初始化方法
 *
 *  @param delegate 代理协议
 *
 *  @return (instancetype)
 */
- (instancetype)initWithDelegate:(nullable id <SSJBaseNetworkServiceDelegate>)delegate;

/**
 *  开始网络请求
 *
 *  @param url    请求的地址
 *  @param params 请求的参数
 */
- (void)request:(NSString *)urlString params:(nullable NSDictionary *)params;

/**
 开始网络请求

 @param urlString 请求的地址
 @param params 请求的参数
 @param success 请求成功的回调
 @param faliure 请求失败的回调
 */
- (void)request:(NSString *)urlString params:(nullable NSDictionary *)params success:(nullable SSJNetworkServiceHandler)success failure:(nullable SSJNetworkServiceHandler)failure;

/**
 *  取消所有未完成的请求
 */
- (void)cancel;

/* ---------------------------------------------------------------- */
/** Overwrite **/
/* ---------------------------------------------------------------- */
/**
 *  请求完成时调用此方法，用来处理返回的结果，需要时子类可以重写此方法，不用调用父类方法
 *
 *  @param rootElement 请求返回的数据
 */
- (void)handleResult:(id)rootElement;

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

NS_ASSUME_NONNULL_END
