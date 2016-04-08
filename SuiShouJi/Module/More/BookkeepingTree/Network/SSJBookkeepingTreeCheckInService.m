//
//  SSJBookkeepingTreeCheckInService.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeCheckInService.h"
#import "SSJBookkeepingTreeCheckInModel.h"

@interface SSJBookkeepingTreeCheckInService ()

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

@end

@implementation SSJBookkeepingTreeCheckInService

- (void)checkIn {
    [self request:SSJURLWithAPI(@"/user/userSignIn.go") params:@{@"cuserid":SSJUSERID()}];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    
    // returnCode为1是签到成功，2是已经签过到
    if ([self.returnCode isEqualToString:@"1"]
        || [self.returnCode isEqualToString:@"2"]) {
        
        NSDictionary *result = [rootElement objectForKey:@"results"];
        NSDictionary *treeInfo = result[@"userTree"];
        
        self.checkInModel.checkInTimes = [treeInfo[@"isignin"] integerValue];
        self.checkInModel.lastCheckInDate = treeInfo[@"isignindate"];
        self.checkInModel.userId = treeInfo[@"cuserid"];
    }
}

- (SSJBookkeepingTreeCheckInModel *)checkInModel {
    if (!_checkInModel) {
        _checkInModel = [[SSJBookkeepingTreeCheckInModel alloc] init];
    }
    return _checkInModel;
}

@end
