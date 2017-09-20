//
//  SSJBannerNetworkService.m
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBannerNetworkService.h"
#import "SSJBannerItem.h"

@implementation SSJBannerNetworkService

- (void)requestBannersList{
    [self request:SSJURLWithAPI(@"/chargebook/config/get_banner.go") params:nil];
}

- (void)handleResult:(NSDictionary *)rootElement{
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *result = [rootElement objectForKey:@"results"];
        self.item = [SSJAdItem mj_objectWithKeyValues:result];
        
    }
    
}



@end
