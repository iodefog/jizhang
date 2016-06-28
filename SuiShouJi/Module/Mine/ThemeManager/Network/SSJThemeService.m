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
        NSDictionary *results = [[rootElement objectForKey:@"results"] objectForKey:@"themeconfig"];
        NSArray *themeArray = [SSJThemeItem mj_objectArrayWithKeyValuesArray:results];
        self.themes = [NSArray arrayWithArray:themeArray];
    }
}
@end
