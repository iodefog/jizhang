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
    NSString *api = @"http://jz.youyuwo.com/app/banner_2.0.json";
    
    NSString *urlStr = [[NSURL URLWithString:api relativeToURL:[NSURL URLWithString:[SSJDomainManager formalDomain]]] absoluteString];
    [self request:urlStr params:nil];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:rootElement];
    self.item = [SSJAdItem mj_objectWithKeyValues:result];
}



@end
