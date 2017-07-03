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
    [self request:SSJURLWithAPI(@"/chargebook/config/about_us.go") params:nil];
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
        
        NSArray *ajkdj = result[@"app"];
        
        self.updateModel = [SSJAppUpdateModel mj_setKeyValues:result[@"app"]];
    }
}

@end
