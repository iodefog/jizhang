//
//  SSJBookkeepingTreeCheckInService.h
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@class SSJBookkeepingTreeCheckInModel;

@interface SSJBookkeepingTreeCheckInService : SSJBaseNetworkService

// 签到次数
@property (nonatomic, strong, readonly) SSJBookkeepingTreeCheckInModel *checkInTimes;

// 签到
- (void)checkIn;

@end
