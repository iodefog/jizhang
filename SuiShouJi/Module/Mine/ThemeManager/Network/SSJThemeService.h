//
//  SSJThemeService.h
//  SuiShouJi
//
//  Created by ricky on 16/6/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJThemeItem.h"

@interface SSJThemeService : SSJBaseNetworkService

//客户端返回的主题
@property(nonatomic, strong) NSArray *themes;

@property (nonatomic, copy) void (^success)(NSArray <SSJThemeItem *> *items);

//请求主题列表
- (void)requestThemeList;
@end
