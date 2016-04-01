//
//  SSJBookkeepingTreeCheckInService.h
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJBookkeepingTreeCheckInService : SSJBaseNetworkService

// 签到次数
@property (nonatomic, copy, readonly) NSString *checkInTimes;

// 上次签到成功日期
@property (nonatomic, copy, readonly) NSString *lastCheckInDate;

// 签到的用户id
@property (nonatomic, copy, readonly) NSString *userId;

// 签到
- (void)checkIn;

@end
