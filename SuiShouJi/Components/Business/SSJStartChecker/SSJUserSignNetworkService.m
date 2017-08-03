//
//  SSJUserSignNetworkService.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserSignNetworkService.h"
#import "SSJStartTextItem.h"
@implementation SSJUserSignNetworkService


- (void)requestUserSignWithStartVer:(NSInteger)startVer {
    
    [self request:SSJURLWithAPI(@"/chargebook/config/start_up.go") params:@{@"startVer" : @(startVer)}];
}

- (void)handleResult:(NSDictionary *)rootElement {
    NSDictionary *resultDic = rootElement[@"results"][@"startupParameter"];
    self.statrLunchItem = [SSJStartLunchItem mj_objectWithKeyValues:resultDic];
    self.statrLunchItem.textImgItem = [SSJStartTextImgItem mj_objectWithKeyValues:resultDic[@"textImg"]];
}
@end
