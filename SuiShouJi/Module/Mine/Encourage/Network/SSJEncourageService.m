//
//  SSJEncourageService.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJEncourageService.h"

@interface SSJEncourageService()


// qq群
@property (nonatomic, copy) NSString *qqgroup;

// qq加群id
@property (nonatomic, copy) NSString *qqgroupId;

// 微信群
@property (nonatomic, copy) NSString *wechatgroup;

// 微信公众号
@property (nonatomic, copy) NSString *wechatId;

// 新浪微博
@property (nonatomic, copy) NSString *sinaBlog;

// 客服电话
@property (nonatomic, copy) NSString *telNum;

// 新浪微博id
@property (nonatomic, copy) NSString *sinaWeiboId;

@end


@implementation SSJEncourageService

- (void)request {
    [self getDefualtData];
    [self requestWithSuccess:NULL failure:NULL];
}

- (void)requestWithSuccess:(SSJNetworkServiceHandler)success
                   failure:(SSJNetworkServiceHandler)failure {
    [self getDefualtData];
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
        self.sinaWeiboId = result[@"sina_blog_id"] ? : @"5603151337";
        self.rewardOpen = [result[@"reward_open"] boolValue];
        self.updateModel = [SSJAppUpdateModel mj_objectWithKeyValues:result[@"app"]];
    }
}

- (BOOL)isRequestSuccessfulWithCode:(NSInteger)code {
    return code == 1;
}

- (void)getDefualtData {
    self.qqgroup = @"552563622";
    self.qqgroupId = @"160aa4d10987c3a6ff17b2fb89e3e1f0e4e996e320207f1e23e1299518f58169";
    self.wechatgroup = @"youyujz01";
    self.wechatId = @"youyujz";
    self.telNum = @"400-7676-298";
    self.sinaBlog = @"有鱼记账";
    self.sinaWeiboId = @"5603151337";
}

@end
