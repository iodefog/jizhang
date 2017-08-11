//
//  SSJMineHomeHeadLineService.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMineHomeHeadLineService.h"
#import "SSJHeadLineItem.h"

@implementation SSJMineHomeHeadLineService

- (void)requestHeadLines {
    [self request:SSJURLWithAPI(@"/chargebook/config/get_headlines.go") params:nil];
}

- (void)handleResult:(NSDictionary *)rootElement {
    NSArray *resultArr = [[rootElement objectForKey:@"results"] objectForKey:@"headlines"];
    self.headLines = [SSJHeadLineItem mj_objectArrayWithKeyValuesArray:resultArr];
}

@end
