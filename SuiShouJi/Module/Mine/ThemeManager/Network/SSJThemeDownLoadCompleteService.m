//
//  SSJThemeDownLoadCompleteService.m
//  SuiShouJi
//
//  Created by ricky on 16/8/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeDownLoadCompleteService.h"

@implementation SSJThemeDownLoadCompleteService

- (void)downloadCompleteThemeWithThemeId:(NSString *)Id{
    self.showLodingIndicator = YES;
    NSDictionary *dic = @{@"cuserId":SSJUSERID(),
                          @"themeId":Id};
    [self request:SSJURLWithAPI(@"/user/themeCount.go") params:dic];
}

@end
