//
//  SSJEncourageService.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJEncourageService.h"

@implementation SSJEncourageService

- (void)request {
    [self requestWithSuccess:NULL failure:NULL];
}

- (void)requestWithSuccess:(SSJNetworkServiceHandler)success
                   failure:(SSJNetworkServiceHandler)failure {
    [self request:@"/chargebook/config/about_us.go" params:nil success:success failure:failure];
}

- (void)handleResult:(NSDictionary *)rootElement {
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *result = [rootElement objectForKey:@"results"];
        self.qqgroup = result[@"qq_group"] ? : @"552563622";
        self.qqgroupId = result[@"group_key"] ? : @"160aa4d10987c3a6ff17b2fb89e3e1f0e4e996e320207f1e23e1299518f58169";
        self.wechatgroup = result[@"wechat_group"] ? : @"youyujz01";
        self.wechatId = result[@"wechat_gzh"] ? : @"youyujz";
        self.telNum = result[@"telephone"] ? : @"400-7676-298";
        self.sinaBlog = result[@"sina_blog"] ? : @"有鱼记账";
                
        self.updateModel = [SSJAppUpdateModel mj_objectWithKeyValues:result[@"app"]];
    }
}

- (BOOL)isRequestSuccessfulWithCode:(NSInteger)code {
    return code == 1;
}

@end
