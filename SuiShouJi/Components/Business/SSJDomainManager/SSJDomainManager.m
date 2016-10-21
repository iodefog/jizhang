//
//  SSJDomainManager.m
//  SuiShouJi
//
//  Created by old lang on 16/10/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDomainManager.h"
#import "AFHTTPSessionManager.h"

static NSString *const kSSJDomainKey = @"kSSJDomainKey";

@implementation SSJDomainManager

+ (void)load {
    [self requestDomainWithSuccess:^{
        
    } failure:^(NSError *error) {
        
    }];
}

+ (void)requestDomainWithSuccess:(void(^)())success failure:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://hosts.shanghaicaiyi.com/gjj/cpixel.cy" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"success:%@",responseObject);
        NSData *decodeData = [[NSData alloc] initWithBase64EncodedData:responseObject options:0];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
    }];
}

+ (NSString *)domain {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kSSJDomainKey];
}

@end
