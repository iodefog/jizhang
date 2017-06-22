//
//  SSJCodeInputEnableService.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCodeInputEnableService.h"

@implementation SSJCodeInputEnableService

- (void)request{
    self.showLodingIndicator = YES;
    [self request:SSJURLWithAPI(@"/chargebook/sharebook/get_secretInputState.go") params:@{@"cuserId":SSJUSERID()}];
}


@end
