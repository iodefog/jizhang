
//
//  SSJUserInfoNetworkService.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserInfoNetworkService.h"

@implementation SSJUserInfoNetworkService

- (void)requestUserInfo{
    self.showLodingIndicator = YES;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [self request:SSJURLWithAPI(@"/user/queryUserInfo.go") params:dict];
}

- (void)handleResult:(NSDictionary *)rootElement{
    [super handleResult:rootElement];
    SSJPRINT(@"%@",self.desc);
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *result = [rootElement objectForKey:@"results"];
        self.item = [SSJUserInfoItem mj_objectWithKeyValues:result];
    }
}

@end
