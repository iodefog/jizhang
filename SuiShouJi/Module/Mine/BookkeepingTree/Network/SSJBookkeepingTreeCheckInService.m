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

- (instancetype)initWithDelegate:(id<SSJBaseNetworkServiceDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        self.requestSerialization = SSJHTTPRequestSerialization;
    }
    return self;
}

- (void)checkIn {
    [self request:SSJURLWithAPI(@"/user/userSignIn.go") params:@{@"cuserid":SSJUSERID()}];
}

- (void)handleResult:(NSDictionary *)rootElement{
    [super handleResult:rootElement];
    
    // returnCode为1是签到成功，2是已经签过到
    if ([self.returnCode isEqualToString:@"1"]
        || [self.returnCode isEqualToString:@"2"]) {
        
        NSDictionary *result = [rootElement objectForKey:@"results"];
        NSDictionary *treeInfo = result[@"userTree"];
        
        self.checkInModel.checkInTimes = [treeInfo[@"isignin"] integerValue];
        self.checkInModel.lastCheckInDate = treeInfo[@"isignindate"];
        self.checkInModel.userId = treeInfo[@"cuserid"];
        self.checkInModel.treeImgUrl = treeInfo[@"userTreeImg"];
        self.checkInModel.treeGifUrl = treeInfo[@"wateringImg"];
    }
}

- (SSJBookkeepingTreeCheckInModel *)checkInModel {
    if (!_checkInModel) {
        _checkInModel = [[SSJBookkeepingTreeCheckInModel alloc] init];
    }
    return _checkInModel;
}

@end
