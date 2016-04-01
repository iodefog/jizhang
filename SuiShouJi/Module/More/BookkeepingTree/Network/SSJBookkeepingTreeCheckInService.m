//
//  SSJBookkeepingTreeCheckInService.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeCheckInService.h"

@interface SSJBookkeepingTreeCheckInService ()

// 签到次数
@property (nonatomic, copy) NSString *checkInTimes;

// 上次签到成功日期
@property (nonatomic, copy) NSString *lastCheckInDate;

// 签到的用户id
@property (nonatomic, copy) NSString *userId;

@end

@implementation SSJBookkeepingTreeCheckInService

- (void)checkIn {
    [self request:SSJURLWithAPI(@"/user/userSignIn.go") params:@{@"cuserid":SSJUSERID()}];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *result = [rootElement objectForKey:@"results"];
        NSDictionary *treeInfo = result[@"userTree"];
        
        _checkInTimes = treeInfo[@"isignin"];
        _lastCheckInDate = treeInfo[@"isignindate"];
        _userId = treeInfo[@"cuserid"];
    }
}

@end
