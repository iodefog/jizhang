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

//
@property (nonatomic, strong, readonly) SSJBookkeepingTreeCheckInModel *checkInModel;

// 签到
- (void)checkIn;

@end
