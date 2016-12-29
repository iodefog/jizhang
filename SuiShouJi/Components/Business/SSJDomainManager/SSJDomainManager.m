//
//  SSJDomainManager.m
//  SuiShouJi
//
//  Created by old lang on 16/10/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDomainManager.h"
#import "AFHTTPSessionManager.h"

// 请求失败后重试的最大次数
const int kMaxRequestFailureTimes = 2;

static NSString *const kSSJDomainKey = @"SSJDomainManagerKey";

static NSString *const kDefaultDomain = @"https://jz.youyuwo.com";
static NSString *const kTestDomain = @"http://192.168.1.51:10012/";
static NSString *const kTestImageDomain = @"http://account.gs.9188.com/jz";

@implementation SSJDomainManager

+ (NSString *)domain {
    return kTestDomain;
//    return [self formalDomain];
//    return kDefaultDomain;
}

+ (NSString *)imageDomain {
    return kTestImageDomain;
//    return [self formalDomain];
//    return kDefaultDomain;
}

+ (void)requestDomain {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self customManager] GET:@"http://hosts.shanghaicaiyi.com/gjj/cpixeljz.cy" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSData *decodeBase64Data = [[NSData alloc] initWithBase64EncodedData:responseObject options:0];
            NSString *decodeBase64Str = [[NSString alloc] initWithData:decodeBase64Data encoding:NSUTF8StringEncoding];
            NSString *jsonStr = [decodeBase64Str cd_AESdecryptWithKey:@"9188gjj123789345" iv:@"9188123123123345"];
            
            NSError *error = nil;
            NSDictionary *domainInfo = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            
            if (error) {
                [self requestAfterFailureIfNeeded];
                return;
            }
            
            NSString *domain = [domainInfo objectForKey:@"domain"];
            [self validateDomain:domain success:^(NSString *domain) {
                [[NSUserDefaults standardUserDefaults] setObject:domain forKey:kSSJDomainKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } failure:^(NSError *error) {
                
            }];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self requestAfterFailureIfNeeded];
        }];
    });
}

+ (AFHTTPSessionManager *)customManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 60;
    return manager;
}

+ (NSString *)formalDomain {
    NSString *domain = [[NSUserDefaults standardUserDefaults] stringForKey:kSSJDomainKey];
    if (domain.length) {
        return domain;
    }
    return kDefaultDomain;
}

+ (void)validateDomain:(NSString *)domain success:(void (^)(NSString *domain))success failure:(void(^)(NSError *error))failure {
    NSString *urlStr = [[NSURL URLWithString:@"/trade/start.go" relativeToURL:[NSURL URLWithString:domain]] absoluteString];
    [[self customManager] POST:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if (response.statusCode == 200) {
                if (success) {
                    success(domain);
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (BOOL)requestAfterFailureIfNeeded {
    static int failureTimes = 0;
    failureTimes ++;
    if (failureTimes <= kMaxRequestFailureTimes) {
        [self requestDomain];
        return YES;
    }
    return NO;
}

@end
