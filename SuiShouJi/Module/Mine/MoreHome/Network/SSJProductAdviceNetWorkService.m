//
//  SSJProductAdviceNetWorkService.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJProductAdviceNetWorkService.h"
#import "SSJAdviceItem.h"
@implementation SSJProductAdviceNetWorkService
//type	int	是	0:查询 1：添加
- (void)requestAdviceMessageListWithType:(SSJAdviceType)type message:(NSString *)messageStr additionalMessage:(NSString *)addMessate{
    self.showLodingIndicator = NO;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:@(1) forKey:@"isystem"];
    [dict setObject:@(1) forKey:@"type"];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [dict setObject:SSJAppVersion() forKey:@"cversion"];
    [dict setObject:SSJPhoneModel() forKey:@"cmodel"];
    [dict setObject:@(SSJSystemVersion()) forKey:@"cphoneos"];
    [dict setObject:messageStr forKey:@"ccontent"];//建议内容
    [dict setObject:addMessate forKey:@"ccontact"];//联系方式
    [dict setObject:@(type) forKey:@"ilabel"];
    [self request:@"/admin/productProposal.go" params:dict];
}

- (void)requestQQDetail {
    [self request:@"/chargebook/config/about_us.go" params:nil];
}

@end
