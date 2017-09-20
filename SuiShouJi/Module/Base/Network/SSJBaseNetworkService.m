
//  SSJBaseNetworkService.m
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJGlobalServiceManager.h"

static inline AFHTTPRequestSerializer *SSJRequestSerializer(SSJRequestSerialization serialization) {
    switch (serialization) {
        case SSJHTTPRequestSerialization:
            return [AFHTTPRequestSerializer serializer];
            break;
            
        case SSJJSONRequestSerialization:
            return [AFJSONRequestSerializer serializer];
            break;
            
        case SSJPropertyListRequestSerialization:
            return [AFPropertyListRequestSerializer serializer];
            break;
    }
};

static inline AFHTTPResponseSerializer *SSJResponseSerializer(SSJResponseSerialization responseSerialization) {
    NSMutableArray *serializers = [NSMutableArray array];
    if ((responseSerialization & SSJJSONResponseSerialization) == SSJJSONResponseSerialization) {
        [serializers addObject:[AFJSONResponseSerializer serializer]];
    }
    if ((responseSerialization & SSJXMLParserResponseSerialization) == SSJXMLParserResponseSerialization) {
        [serializers addObject:[AFXMLParserResponseSerializer serializer]];
    }
    if ((responseSerialization & SSJPropertyListResponseSerialization) == SSJPropertyListResponseSerialization) {
        [serializers addObject:[AFPropertyListResponseSerializer serializer]];
    }
    if ((responseSerialization & SSJImageResponseSerialization) == SSJImageResponseSerialization) {
        [serializers addObject:[AFImageResponseSerializer serializer]];
    }
    
    if (serializers.count > 1) {
        return [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:serializers];
    } else {
        AFHTTPResponseSerializer *serializer = [serializers firstObject];
        serializer = serializer ?: [AFHTTPResponseSerializer serializer];
        return serializer;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJBaseNetworkServiceHandlerManager
#pragma mark -

@interface _SSJBaseNetworkServiceHandlerManager : NSObject

@property (nonatomic, weak) SSJBaseNetworkService *service;

@property (nonatomic, strong) NSMutableDictionary *successHandlers;

@property (nonatomic, strong) NSMutableDictionary *failureHandlers;

- (void)addSuccessHandler:(SSJNetworkServiceHandler)success forIdentifier:(NSUInteger)identifier;

- (void)addFailureHandler:(SSJNetworkServiceHandler)failure forIdentifier:(NSUInteger)identifier;

- (void)performSuccessHandlerForIdentifier:(NSUInteger)identifier;

- (void)performFailureHandlerForIdentifier:(NSUInteger)identifier;

@end

@implementation _SSJBaseNetworkServiceHandlerManager

- (instancetype)initWithService:(SSJBaseNetworkService *)service {
    if (self = [super init]) {
        self.service = service;
        self.successHandlers = [NSMutableDictionary dictionary];
        self.failureHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addSuccessHandler:(SSJNetworkServiceHandler)success forIdentifier:(NSUInteger)identifier {
    self.successHandlers[@(identifier)] = success;
}

- (void)addFailureHandler:(SSJNetworkServiceHandler)failure forIdentifier:(NSUInteger)identifier {
    self.failureHandlers[@(identifier)] = failure;
}

- (void)performSuccessHandlerForIdentifier:(NSUInteger)identifier {
    SSJNetworkServiceHandler success = self.successHandlers[@(identifier)];
    if (success) {
        success(self.service);
        self.successHandlers[@(identifier)] = nil;
    }
    self.failureHandlers[@(identifier)] = nil;
}

- (void)performFailureHandlerForIdentifier:(NSUInteger)identifier {
    SSJNetworkServiceHandler failure = self.failureHandlers[@(identifier)];
    if (failure) {
        failure(self.service);
        self.failureHandlers[@(identifier)] = nil;
    }
    self.successHandlers[@(identifier)] = nil;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJBaseNetworkService
#pragma mark -

@interface SSJBaseNetworkService ()

@property (nonatomic) SSJNetworkServiceState state;

@property (nonatomic, strong, nullable) NSError *error;

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, strong) _SSJBaseNetworkServiceHandlerManager *handlerManager;

@end

@implementation SSJBaseNetworkService

- (instancetype)init {
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id <SSJBaseNetworkServiceDelegate>)delegate {
    if (self = [super init]) {
        _showMessageIfErrorOccured = YES;
        _delegate = delegate;
        _httpMethod = SSJBaseNetworkServiceHttpMethodPOST;
        _timeoutInterval = 60;
        _httpsOpened = YES;
        _requestSerialization = SSJHTTPRequestSerialization;
        _responseSerialization = SSJJSONResponseSerialization;
        
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [self.formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss"];
        
        self.handlerManager = [[_SSJBaseNetworkServiceHandlerManager alloc] initWithService:self];
    }
    return self;
}

- (void)request:(NSString *)urlString params:(nullable NSDictionary *)params {
    [self request:urlString params:params success:NULL failure:NULL];
}

- (void)request:(NSString *)urlString params:(nullable NSDictionary *)params success:(nullable SSJNetworkServiceHandler)success failure:(nullable SSJNetworkServiceHandler)failure {
    [self.task cancel];
    
    self.error = nil;
    self.state = SSJNetworkServiceStateLoading;
    [SSJGlobalServiceManager removeService:self];
    
    SSJGlobalServiceManager *manager = [self p_customManager];
    NSDictionary *paramsDic = [self p_packParameters:params];
    NSString *fullUrlString = [[NSURL URLWithString:urlString relativeToURL:manager.baseURL] absoluteString];
    
    switch (_httpMethod) {
        case SSJBaseNetworkServiceHttpMethodPOST: {
            self.task = [manager POST:urlString parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
                [self p_setServerTimeWithResponse:(NSHTTPURLResponse *)task.response];
                [self p_taskDidFinish:task responseObject:responseObject];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self p_taskDidFail:task error:error];
            }];
            
            SSJPRINT(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< POST start >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\
                     \n-----------------------------------------------------------------------------------\
                     \nURL:%@\
                     \n-----------------------------------------------------------------------------------\
                     \nheaders:%@ \
                     \n-----------------------------------------------------------------------------------\
                     \nparameters:%@\
                     \n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< POST end >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\
                     ", fullUrlString, self.task.currentRequest.allHTTPHeaderFields, paramsDic);
        }   break;
            
        case SSJBaseNetworkServiceHttpMethodGET: {
            self.task = [manager GET:urlString parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
                [self p_setServerTimeWithResponse:(NSHTTPURLResponse *)task.response];
                [self p_taskDidFinish:task responseObject:responseObject];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self p_taskDidFail:task error:error];
            }];
            
            SSJPRINT(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< GET start >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\
                     \n-----------------------------------------------------------------------------------\
                     \nURL:%@\
                     \n-----------------------------------------------------------------------------------\
                     \nheaders:%@ \
                     \n-----------------------------------------------------------------------------------\
                     \nparameters:%@\
                     \n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< GET end >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\
                     ", fullUrlString, self.task.currentRequest.allHTTPHeaderFields, paramsDic);
        }   break;
    }
    
    [self.handlerManager addSuccessHandler:success forIdentifier:self.task.taskIdentifier];
    [self.handlerManager addFailureHandler:failure forIdentifier:self.task.taskIdentifier];
    
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
    self.state = SSJNetworkServiceStateCanceled;
    if (_delegate && [_delegate respondsToSelector:@selector(serverDidCancel:)]) {
        [_delegate serverDidCancel:self];
    }
}

- (BOOL)isLoaded {
    return self.state == SSJNetworkServiceStateFailed || self.state == SSJNetworkServiceStateSuccessful;
}

//--------------------------------
/** 需要子类覆写的方法 **/
//--------------------------------
- (void)handleResult:(NSDictionary *)rootElement {
}

- (BOOL)isRequestSuccessfulWithCode:(NSInteger)code {
    return YES;
}

#pragma mark - Private
/* 基础参数 */
- (NSDictionary<NSString *, NSString *> *)p_basicParameters {
    return @{@"source":SSJDefaultSource(),
             @"releaseVersion":SSJAppVersion(),
             @"accessToken":(SSJAccessToken() ?: @""),
             @"appId":(SSJAppId() ?: @"")};
}

/* 封装参数 */
- (NSMutableDictionary *)p_packParameters:(NSDictionary *)params {
    NSMutableDictionary *paraDic = params ? [params mutableCopy] : [[NSMutableDictionary alloc] init];
    [self.p_basicParameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        paraDic[key] = obj;
    }];
    return paraDic;
}

/* 配置manager */
- (SSJGlobalServiceManager *)p_customManager {
    SSJGlobalServiceManager *manager = [SSJGlobalServiceManager sharedManager];
    manager.httpsOpened = _httpsOpened;
    manager.responseSerializer = SSJResponseSerializer(_responseSerialization);
    manager.requestSerializer = SSJRequestSerializer(_requestSerialization);
    manager.requestSerializer.timeoutInterval = _timeoutInterval;
    if (self.httpMethod == SSJBaseNetworkServiceHttpMethodPOST) {
        [self.p_basicParameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
        [manager.requestSerializer setValue:SSJUSERID() forHTTPHeaderField:@"cuserId"];
    }
    [manager.operationQueue setMaxConcurrentOperationCount:1];
    return manager;
}

/* 请求完成 */
- (void)p_taskDidFinish:(NSURLSessionTask *)task responseObject:(NSDictionary *)responseObject {
    if (self.task.state == NSURLSessionTaskStateCompleted) {
        
        self.task = nil;
        self.state = SSJNetworkServiceStateSuccessful;
        _rootElement = responseObject;
        
        if ([_rootElement isKindOfClass:[NSDictionary class]]) {
            id returnCode = [_rootElement objectForKey:@"code"];
            if ([returnCode isKindOfClass:[NSNumber class]]) {
                _returnCode = [NSString stringWithFormat:@"%@",returnCode];
            } else if ([returnCode isKindOfClass:[NSString class]]) {
                _returnCode = returnCode;
            }
            
            _desc = [_rootElement objectForKey:@"desc"];
        }
        
        NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)task.response;
        SSJPRINT(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Request success >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\
                 \n-----------------------------------------------------------------------------------------\
                 \nURL:%@   code:%@   desc:%@\
                 \n-----------------------------------------------------------------------------------------\
                 \nheader:%@ \
                 \n-----------------------------------------------------------------------------------------\
                 \ndata:%@\
                 \n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< End >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\
                 ", task.currentRequest.URL, _returnCode, _desc, httpUrlResponse.allHeaderFields, _rootElement);
        
        [self handleResult:_rootElement];
        
        [SSJGlobalServiceManager removeService:self];
        
        NSInteger code = [self.returnCode integerValue];
        if ([self isRequestSuccessfulWithCode:code]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(serverDidFinished:)]) {
                [self.delegate serverDidFinished:self];
            }
            [self.handlerManager performSuccessHandlerForIdentifier:task.taskIdentifier];
        } else {
            self.error = [NSError errorWithDomain:SSJErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:self.desc}];
            if (self.delegate && [self.delegate respondsToSelector:@selector(server:didFailLoadWithError:)]) {
                [self.delegate server:self didFailLoadWithError:self.error];
            }
            [self.handlerManager performFailureHandlerForIdentifier:task.taskIdentifier];
        }
    }
}

/* 请求失败 */
- (void)p_taskDidFail:(NSURLSessionTask *)task error:(NSError *)error {
    if (self.task.state == NSURLSessionTaskStateCompleted ||
        self.task.state == NSURLSessionTaskStateCanceling) {
        
        self.task = nil;
        
        // 取消请求
        if (self.state == SSJNetworkServiceStateCanceled) {
            [SSJGlobalServiceManager removeService:self];
            return;
        }
        
        // 请求失败
        self.state = SSJNetworkServiceStateFailed;
        self.error = error;
        [SSJGlobalServiceManager removeService:self];
        
        NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)task.response;
        SSJPRINT(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Request failed >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\
                 \n-----------------------------------------------------------------------------------------\
                 \nURL:%@   code:%d   desc:%@\
                 \n-----------------------------------------------------------------------------------------\
                 \nheader:%@ \
                 \n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< End >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\
                 ", task.currentRequest.URL, (int)[error code], [error localizedDescription], httpUrlResponse.allHeaderFields);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(server:didFailLoadWithError:)]) {
            [self.delegate server:self didFailLoadWithError:error];
        }
        [self.handlerManager performFailureHandlerForIdentifier:task.taskIdentifier];
    }
}

//  解析header中的服务器时间
- (void)p_setServerTimeWithResponse:(NSHTTPURLResponse *)response {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return;
    }
    
    NSString *datestring = [response.allHeaderFields objectForKey:@"Date"];
    datestring = [datestring stringByReplacingOccurrencesOfString:@" GMT" withString:@""];
    
    //  只能设置成美国时区，否则时间格式无法转换
    NSDate *date = [self.formatter dateFromString:datestring];
    
    _serverDate = [date dateByAddingTimeInterval:(60 * 60 * 8)];
//    SSJPRINT(@">>> current server date:%@",_serverDate);
}

@end

