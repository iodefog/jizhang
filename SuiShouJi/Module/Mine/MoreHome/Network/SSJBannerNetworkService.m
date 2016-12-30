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
#ifdef DEBUG
    [self request:@"https://jz.youyuwo.com/app/banner_test.json" params:nil];
#else
    [self request:@"/app/banner_test.json" params:nil];
#endif
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:rootElement];
    self.item = [SSJAdItem mj_objectWithKeyValues:result];
}


@end
