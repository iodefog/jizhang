//
//  SSJBannerNetworkService.m
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBannerNetworkService.h"
#import "SSJDomainManager.h"
#import "SSJBannerItem.h"


@implementation SSJBannerNetworkService

- (void)requestBannersList{

    [self request:SSJURLWithAPI(@"/chargebook/config/get_banner.go") params:nil];
}

- (void)handleResult:(NSDictionary *)rootElement{
    [super handleResult:rootElement];
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:rootElement];
    self.item = [SSJAdItem mj_objectWithKeyValues:result];
}



@end
