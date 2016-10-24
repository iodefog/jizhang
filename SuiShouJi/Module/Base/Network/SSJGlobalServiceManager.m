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
            
            manager = [[SSJGlobalServiceManager alloc] initWithBaseURL:[NSURL URLWithString:[SSJDomainManager domain]] sessionConfiguration:configuration];
        }
    });
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
    }
    return self;
}

- (void)setSSLPinningMode:(AFSSLPinningMode)SSLPinningMode {
    if (_SSLPinningMode != SSLPinningMode) {
        _SSLPinningMode = SSLPinningMode;
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:SSLPinningMode];
        if (SSLPinningMode == AFSSLPinningModePublicKey ||
            SSLPinningMode == AFSSLPinningModeCertificate) {
//            if ([[NSFileManager defaultManager] fileExistsAtPath:SSJSSLCertificatePath()]) {
//                [self p_reloadPinnedCertificates];
//            }
        }
    }
}

- (void)setAllowInvalidCertificates:(BOOL)allowInvalidCertificates {
    _allowInvalidCertificates = allowInvalidCertificates;
    self.securityPolicy.allowInvalidCertificates = allowInvalidCertificates;
}

- (void)setValidatesDomainName:(BOOL)validatesDomainName {
    _validatesDomainName = validatesDomainName;
    self.securityPolicy.validatesDomainName = validatesDomainName;
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
