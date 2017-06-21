//
//  SSJThemeService.m
//  SuiShouJi
//
//  Created by ricky on 16/6/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeService.h"

@implementation SSJThemeService

- (void)requestThemeList{
    self.showLodingIndicator = YES;
    [self request:SSJURLWithAPI(@"/user/themes.go") params:nil];
}

- (void)handleResult:(NSDictionary *)rootElement{
    [super handleResult:rootElement];
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *results = [rootElement objectForKey:@"results"];
        NSMutableArray *themeArray = [SSJThemeItem mj_objectArrayWithKeyValuesArray:[results objectForKey:@"themeconfig"]];
        SSJThemeItem *itemDefualt = [[SSJThemeItem alloc]init];
        itemDefualt.themeId = @"0";
        itemDefualt.themeTitle = @"官方白";
        itemDefualt.themeDesc = @"官方默认皮肤，羞羞萌萌的小猫伴你走过记账囧途，简约的初心设计与你一路相随。";
        [themeArray insertObject:itemDefualt atIndex:0];
        SSJThemeItem *itemCustom = [[SSJThemeItem alloc]init];
        itemCustom.themeId = @"-1";
        itemCustom.themeTitle = @"自定义背景";
        [themeArray insertObject:itemCustom atIndex:0];
        self.themes = [NSArray arrayWithArray:themeArray];
        if (self.success) {
            self.success(self.themes);
        }
    }
}
@end
