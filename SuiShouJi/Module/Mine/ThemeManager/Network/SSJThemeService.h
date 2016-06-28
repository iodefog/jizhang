//
//  SSJThemeService.h
//  SuiShouJi
//
//  Created by ricky on 16/6/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJThemeService : SSJBaseNetworkService
@property(nonatomic, strong) NSArray *themes;
- (void)requestThemeList;
@end
