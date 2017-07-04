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
        self.qqgroup = result[@"qq_group"];
        self.qqgroupId = result[@"group_key"];
        self.wechatgroup = result[@"wechat_group"];
        self.wechatId = result[@"wechat_gzh"];
        self.telNum = result[@"telephone"];
        self.sinaBlog = result[@"sina_blog"];
                
        self.updateModel = [SSJAppUpdateModel mj_objectWithKeyValues:result[@"app"]];
    }
}

- (BOOL)isRequestSuccessfulWithCode:(NSInteger)code {
    return code == 1;
}

@end
