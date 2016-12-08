//
//  SSJBannerNetworkService.m
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBannerNetworkService.h"

@implementation SSJBannerNetworkService

- (void)requestBannersList{
    self.showLodingIndicator = NO;
    [self request:@"http://jz.9188.com/app/banner_testnew.json" params:nil];
}

- (void)requestDidFinish:(id)rootElement{
    [super requestDidFinish:rootElement];
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:rootElement];
    self.item = [SSJAdItem mj_objectWithKeyValues:result];
}


@end
