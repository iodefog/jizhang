//
//  SSJNewDotNetworkService.h
//  SuiShouJi
//
//  Created by yi cai on 2017/1/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//  是否显示小红点

#import "SSJBaseNetworkService.h"

static NSString *const kThemeVersionKey = @"kThemeVersionKey";
static NSString *const kUserItemReturnKey = @"kUserItemReturnKey";

@class SSJThemeAndAdviceDotItem;

@interface SSJNewDotNetworkService : SSJBaseNetworkService

@property (nonatomic, strong) SSJThemeAndAdviceDotItem *dotItem;

//当前主题版本号，最新一条建议回复时间
- (void)requestThemeAndAdviceUpdate;

@end
