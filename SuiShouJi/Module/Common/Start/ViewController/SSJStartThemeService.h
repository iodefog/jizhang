//
//  SSJStartThemeService.h
//  SuiShouJi
//
//  Created by ricky on 2017/9/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJThemeItem.h"

@interface SSJStartThemeService : SSJBaseNetworkService

@property (nonatomic, strong) NSArray <SSJThemeItem *> *themeItems;

- (void)requestWithThemeIds:(NSArray *)themeIds;

@end
