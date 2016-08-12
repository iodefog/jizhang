//
//  SSJPasswordModifyService.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPasswordModifyService.h"

@implementation SSJPasswordModifyService

-(void)modifyPasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword{
    self.showLodingIndicator = YES;
    NSString *userid = SSJUSERID();
    NSDictionary *dict=[[NSDictionary alloc]init];
    dict = @{@"cuserid":userid,
            @"oldValue":oldPassword,
            @"newValue":newPassword};
    [self request:SSJURLWithAPI(@"/user/modify.go") params:dict];
}

@end
