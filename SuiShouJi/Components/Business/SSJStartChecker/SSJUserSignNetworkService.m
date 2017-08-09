//
//  SSJUserSignNetworkService.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserSignNetworkService.h"
#import "SSJStartTextItem.h"
@implementation SSJUserSignNetworkService


- (void)requestUserSign {
    NSInteger startVer = [[[NSUserDefaults standardUserDefaults] stringForKey:SSJLunchStartVerKey] integerValue];
    [self request:SSJURLWithAPI(@"/chargebook/config/start_up.go") params:@{@"startVer" : @(startVer)}];
}

- (void)handleResult:(NSDictionary *)rootElement {
    NSDictionary *results = [rootElement objectForKey:@"results"];
    if (!results.count) {
        NSData *startLunchData = [[NSUserDefaults standardUserDefaults] objectForKey:SSJLunchUserSignItemKey];
        if (startLunchData) {
            SSJStartLunchItem *startLunchItem = [NSKeyedUnarchiver unarchiveObjectWithData:startLunchData];
            self.statrLunchItem = startLunchItem;
        }
        return;
    }
    NSDictionary *resultDic = rootElement[@"results"][@"startupParameter"];
    self.statrLunchItem = [SSJStartLunchItem mj_objectWithKeyValues:resultDic];
    self.statrLunchItem.textImgItem = [SSJStartTextImgItem mj_objectWithKeyValues:resultDic[@"textImg"]];
    //保存startVer SSJLunchStartVerKey
    //保存模型
    NSData *startLunchData = [NSKeyedArchiver archivedDataWithRootObject:self.statrLunchItem];
    [[NSUserDefaults standardUserDefaults] setObject:startLunchData forKey:SSJLunchUserSignItemKey];
    
    NSString *startVer = [[NSUserDefaults standardUserDefaults] stringForKey:SSJLunchStartVerKey];
    if (![self.statrLunchItem.startVer isEqualToString:startVer]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.statrLunchItem.startVer forKey:SSJLunchStartVerKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
