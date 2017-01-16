//
//  SSJBannerNetworkService.m
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBannerNetworkService.h"
#import "SSJDomainManager.h"
@implementation SSJBannerNetworkService

- (void)requestBannersList{
    self.showLodingIndicator = NO;
//    if ([[SSJDomainManager domain] isEqualToString:kDefaultDomain]) {
//        [self request:@"https://jz.youyuwo.com/app/new_banners.json" params:nil];
//    } else {
//        [self request:@"https://jz.youyuwo.com/app/banner_test.json" params:nil];
//    }
    [self request:@"http://jz.youyuwo.com/app/banner_2.0.json" params:nil];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:rootElement];
    self.item = [SSJAdItem mj_objectWithKeyValues:result];
}


@end
