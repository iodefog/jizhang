//
//  SSJStartThemeService.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJStartThemeService.h"

@implementation SSJStartThemeService

- (void)requestWithThemeIds:(NSArray *)themeIds {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:[themeIds componentsJoinedByString:@","] forKey:@"themeIds"];
    [self request:SSJURLWithAPI(@"/chargebook/config/get_themes.go") params:dic];
}

- (void)handleResult:(NSDictionary *)rootElement {
    if ([self.returnCode isEqualToString:@"1"]) {
        NSArray *themeArr = [[rootElement objectForKey:@"results"] objectForKey:@"themeconfig"];
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[SSJThemeItem mj_objectArrayWithKeyValuesArray:themeArr]];
        SSJThemeItem *item = [[SSJThemeItem alloc] init];
        item.themeId = @"0";
        [tempArr insertObject:item atIndex:0];
        self.themeItems = tempArr;
    }
}

@end
