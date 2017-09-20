//
//  SSJGlobalServiceManager.m
//  MoneyMore
//
//  Created by old lang on 15-4-9.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJGlobalServiceManager.h"
#import "CDPointActivityIndicator.h"
#import "SSJDomainManager.h"

@interface SSJGlobalServiceManager ()

@property (readwrite, nonatomic, strong) NSMutableArray *services;

@end

@implementation SSJGlobalServiceManager

+ (instancetype)sharedManager {
    static SSJGlobalServiceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            
            manager = [[SSJGlobalServiceManager alloc] initWithBaseURL:[SSJDomainManager domain] sessionConfiguration:configuration];
        }
    });
    return manager;
}

+ (instancetype)standardManager {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    SSJGlobalServiceManager *manager = [[SSJGlobalServiceManager alloc] initWithBaseURL:[SSJDomainManager domain] sessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.httpsOpened = YES;
    
    return manager;
}

+ (void)addService:(SSJBaseNetworkService *)service {
    SSJGlobalServiceManager *manager = [SSJGlobalServiceManager sharedManager];
    if (![manager.services containsObject:service]) {
        if (service.showLodingIndicator && ![manager p_hasLoadingIndicator]) {
            [CDPointActivityIndicator startAnimating];
        }
        [manager.services addObject:service];
        [manager p_showNetworkIndicatorIfNeeded];
    }
}

+ (void)removeService:(SSJBaseNetworkService *)service {
    SSJGlobalServiceManager *manager = [SSJGlobalServiceManager sharedManager];
    if ([manager.services containsObject:service]) {
        [manager.services removeObject:service];
        [manager p_showNetworkIndicatorIfNeeded];
        if (![manager p_hasLoadingIndicator]/* && service.showLodingIndicator*/) {
            [CDPointActivityIndicator stopAnimating];
        }
    }
}

+ (void)reloadPinnedCertificates {
//    [[SSJGlobalServiceManager sharedManager] p_reloadPinnedCertificates];
}

- (instancetype)initWithBaseURL:(NSURL *)url
           sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if (self = [super initWithBaseURL:url sessionConfiguration:configuration]) {
        _services = [[NSMutableArray alloc] init];
        self.securityPolicy = [self securityPolicy];
    }
    return self;
}

- (AFSecurityPolicy *)securityPolicy {
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:(_httpsOpened ? AFSSLPinningModeCertificate : AFSSLPinningModeNone)];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = NO;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    securityPolicy.validatesCertificateChain = NO; // 不用验证整个服务器的证书串，因为目前服务器包含客户端没有的证书
    
    return securityPolicy;
}

- (void)setHttpsOpened:(BOOL)httpsOpened {
    if (_httpsOpened != httpsOpened) {
        _httpsOpened = httpsOpened;
        self.securityPolicy = [self securityPolicy];
    }
}

//  如果当前有请求，就显示状态栏上的加载图标；反之不显示
- (void)p_showNetworkIndicatorIfNeeded {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = _services.count > 0;
}

//  遍历所有service，返回是否有servicer显示加载框
- (BOOL)p_hasLoadingIndicator {
    __block BOOL shouldShowLoading = NO;
    [_services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SSJBaseNetworkService *service = obj;
        if (service.showLodingIndicator) {
            shouldShowLoading = YES;
            *stop = YES;
        }
    }];
    return shouldShowLoading;
}

//  重新加载SSL证书
- (void)p_reloadPinnedCertificates {
    NSData *SSLData = [NSData dataWithContentsOfFile:SSJSSLCertificatePath()];
    self.securityPolicy.pinnedCertificates = @[SSLData];
}

@end
