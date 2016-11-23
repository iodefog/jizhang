
//  SSJBaseNetworkService.m
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJGlobalServiceManager.h"
#import "SSJDomainManager.h"

@interface SSJBaseNetworkService ()

@property (readwrite, nonatomic) BOOL isLoaded;
@property (readwrite, nonatomic) BOOL isCancelled;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation SSJBaseNetworkService

- (instancetype)init {
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id <SSJBaseNetworkServiceDelegate>)delegate {
    if (self = [super init]) {
        _isLoginService = YES;
        _showMessageIfErrorOccured = YES;
        _delegate = delegate;
        _httpMethod = SSJBaseNetworkServiceHttpMethodPOST;
        _timeoutInterval = 60;
        _pinningMode = AFSSLPinningModeCertificate;
        _allowInvalidCertificates = YES;
        _validatesDomainName = YES;
        
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [self.formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss"];
    }
    return self;
}

- (void)request:(NSString *)urlString params:(id)params {
    [self.task cancel];
    self.isCancelled = NO;
    [SSJGlobalServiceManager removeService:self];
    
    SSJGlobalServiceManager *manager = [self p_customManager];
    
    NSDictionary *paramsDic = [self packParameters:params];
    NSString *fullUrlString = [[NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:[SSJDomainManager domain]]] absoluteString];
    
    switch (_httpMethod) {
        case SSJBaseNetworkServiceHttpMethodPOST: {
            self.task = [manager POST:urlString parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
                NSURLResponse *response = task.response;
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)response;
                    [self p_setServerTimeWithHeaders:httpUrlResponse.allHeaderFields];
                }
                if ([self isKindOfClass:[SSJBaseNetworkService class]]) {
                    _isLoaded = YES;
                    _isLoadSuccess = YES;
                    [self p_taskDidFinish:task responseObject:responseObject];
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if ([self isKindOfClass:[SSJBaseNetworkService class]]) {
                    _isLoaded = YES;
                    _isLoadSuccess = NO;
                    
                    [self p_taskDidFail:task error:error];
                    
                }
            }];
            
            SSJPRINT(@">>> POST request url:%@",fullUrlString);
            SSJPRINT(@">>> POST request parameters:\n%@",paramsDic);
        }   break;
            
        case SSJBaseNetworkServiceHttpMethodGET: {
            self.task = [manager GET:urlString parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
                if ([self isKindOfClass:[SSJBaseNetworkService class]]) {
                    self -> _isLoaded = YES;
                    [self p_taskDidFinish:task responseObject:responseObject];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if ([self isKindOfClass:[SSJBaseNetworkService class]]) {
                    [self p_taskDidFail:task error:error];
                }
            }];
            
            SSJPRINT(@">>> GET request url:%@",fullUrlString);
            SSJPRINT(@">>> GET request parameters:\n%@",paramsDic);
        }   break;
    }
    
    [SSJGlobalServiceManager addService:self];
    if (_delegate && [_delegate respondsToSelector:@selector(serverDidStart:)]) {
        [_delegate serverDidStart:self];
    }
}

- (void)cancel {
    if (!self.task
        || self.task.state == NSURLSessionTaskStateCanceling
        || self.task.state == NSURLSessionTaskStateCompleted) {
        return;
    }
    
    [self.task cancel];
    self.isCancelled = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(serverDidCancel:)]) {
        [_delegate serverDidCancel:self];
    }
}

- (BOOL)isLoading {
    return (self.task && (self.task.state == NSURLSessionTaskStateRunning ||
                          self.task.state == NSURLSessionTaskStateSuspended));
}

/* 封装参数 */
- (NSMutableDictionary *)packParameters:(NSMutableDictionary *)params {
    NSMutableDictionary *paraDic = params ? [params mutableCopy] : [[NSMutableDictionary alloc] init];
    [paraDic setObject:SSJDefaultSource() forKey:@"source"];
//    [paraDic setObject:SSJAppVersion() forKey:@"appVersion"];
    [paraDic setObject:SSJAppVersion() forKey:@"releaseVersion"];
    if (_isLoginService) {
        [paraDic setObject:(SSJAccessToken() ?: @"") forKey:@"accessToken"];
        [paraDic setObject:(SSJAppId() ?: @"") forKey:@"appId"];
    }
    return paraDic;
}

/* 配置manager */
- (SSJGlobalServiceManager *)p_customManager {
    SSJGlobalServiceManager *manager = [SSJGlobalServiceManager sharedManager];
    manager.SSLPinningMode = _pinningMode;
    manager.allowInvalidCertificates = _allowInvalidCertificates;
    manager.validatesDomainName = _validatesDomainName;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = _timeoutInterval;
    [manager.operationQueue setMaxConcurrentOperationCount:1];
    return manager;
}

/* 请求完成 */
- (void)p_taskDidFinish:(NSURLSessionTask *)task responseObject:(id)responseObject {
    if (self.task.state == NSURLSessionTaskStateCompleted) {
        
        self.task = nil;
        _rootElement = responseObject;
        
        SSJPRINT(@">>> response data:%@ URL:%@",_rootElement, task.currentRequest.URL);
        
        if ([_rootElement isKindOfClass:[NSDictionary class]]) {
            id returnCode = [_rootElement objectForKey:@"code"];
            if ([returnCode isKindOfClass:[NSNumber class]]) {
                _returnCode = [NSString stringWithFormat:@"%@",returnCode];
            } else if ([returnCode isKindOfClass:[NSString class]]) {
                _returnCode = returnCode;
            }
            
            _desc = [_rootElement objectForKey:@"desc"];
            SSJPRINT(@"%@",_desc);
        }
        
        [self requestDidFinish:_rootElement];
        
        [SSJGlobalServiceManager removeService:self];
        if (self.delegate && [self.delegate respondsToSelector:@selector(serverDidFinished:)]) {
            [self.delegate serverDidFinished:self];
        }
    }
}

/* 请求失败 */
- (void)p_taskDidFail:(NSURLSessionTask *)task error:(NSError *)error {
    if (self.task.state == NSURLSessionTaskStateCompleted ||
        self.task.state == NSURLSessionTaskStateCanceling) {
        
        self.task = nil;
        
        //  取消请求
        if (self.isCancelled/*error.code == kCFURLErrorCancelled*/) {
            [SSJGlobalServiceManager removeService:self];
            return;
        }
        
        //  请求失败
        [SSJGlobalServiceManager removeService:self];
        
        NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"%@",httpUrlResponse.allHeaderFields);
        
        SSJPRINT(@">>> response error:%@ URL:%@",[error localizedDescription], task.currentRequest.URL);
        if (self.delegate && [self.delegate respondsToSelector:@selector(server:didFailLoadWithError:)]) {
            [self.delegate server:self didFailLoadWithError:error];
        }
    }
}

//  解析header中的服务器时间
- (void)p_setServerTimeWithHeaders:(NSDictionary *)headers {
    NSString *datestring = [headers objectForKey:@"Date"];
    datestring = [datestring stringByReplacingOccurrencesOfString:@" GMT" withString:@""];
    
    //  只能设置成美国时区，否则时间格式无法转换
    NSDate *date = [self.formatter dateFromString:datestring];
    
    _serverDate = [date dateByAddingTimeInterval:(60 * 60 * 8)];
    SSJPRINT(@">>> current server date:%@",_serverDate);
}

//--------------------------------
/** 需要子类覆写的方法 **/
//--------------------------------
- (void)requestDidFinish:(id)rootElement {
    
}

@end

