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
    [self request:@"http://10.0.11.11/theme.json" params:nil];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
#warning test
//    if ([self.returnCode isEqualToString:@"1"]) {
//        NSDictionary *results = [rootElement objectForKey:@"results"];
        NSMutableArray *themeArray = [SSJThemeItem mj_objectArrayWithKeyValuesArray:[rootElement objectForKey:@"themeconfig"]];
        SSJThemeItem *item = [[SSJThemeItem alloc]init];
        item.themeId = @"0";
        item.themeTitle = @"官方白";
        item.themeDesc = @"官方默认皮肤，羞羞萌萌的小猫伴你走过记账囧途，简约的初心设计与你一路相随。";
        [themeArray insertObject:item atIndex:0];
        self.themes = [NSArray arrayWithArray:themeArray];
        if (self.success) {
            self.success(self.themes);
        }
//    }
}
@end
