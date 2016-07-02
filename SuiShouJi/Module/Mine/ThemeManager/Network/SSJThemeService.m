//
//  SSJThemeService.m
//  SuiShouJi
//
//  Created by ricky on 16/6/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeService.h"
#import "SSJThemeItem.h"

@implementation SSJThemeService

- (void)requestThemeList{
    [self request:SSJURLWithAPI(@"/user/themes.go") params:nil];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *results = [rootElement objectForKey:@"results"];
        NSMutableArray *themeArray = [SSJThemeItem mj_objectArrayWithKeyValuesArray:[results objectForKey:@"themeconfig"]];
        SSJThemeItem *item = [[SSJThemeItem alloc]init];
        item.themeId = @"0";
        item.themeTitle = @"官方白";
        item.themeDesc = @"官方默认皮肤，羞羞萌萌的小猫伴你走过记账囧途，简约的初心设计与你一路相随。";
        [themeArray insertObject:item atIndex:0];
        self.themes = [NSArray arrayWithArray:themeArray];
    }
}
@end
