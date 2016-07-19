//
//  SSJBannerNetworkService.h
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJBannerNetworkService : SSJBaseNetworkService

@property(nonatomic, strong) NSArray *items;

- (void)requestBannersList;

@end
