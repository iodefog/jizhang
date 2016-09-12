//
//  SSJBannerNetworkService.h
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJAdItem.h"

@interface SSJBannerNetworkService : SSJBaseNetworkService

@property(nonatomic, strong) SSJAdItem *item;

- (void)requestBannersList;

@end
