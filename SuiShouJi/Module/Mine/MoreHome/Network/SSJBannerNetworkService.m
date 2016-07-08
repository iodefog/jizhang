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
    self.showLodingIndicator = YES;
    [self request:@"http://jz.9188.com/app/banner.json" params:nil];
}

- (void)requestDidFinish:(id)rootElement{
    [super requestDidFinish:rootElement];
}


@end
