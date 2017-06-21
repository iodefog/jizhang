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
//ec560ecc-f0de-4638-ae37-ebeaf5c8b5c2
- (void)requestAdviceMessageListWithType:(int)type message:(NSString *)messageStr additionalMessage:(NSString *)addMessate{
    self.showLodingIndicator = NO;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [dict setObject:@(1) forKey:@"isystem"];
    [dict setObject:SSJAppVersion() forKey:@"cversion"];
    [dict setObject:SSJPhoneModel() forKey:@"cmodel"];
    [dict setObject:@(SSJSystemVersion()) forKey:@"cphoneos"];

    if (type == 1) {
        [dict setObject:messageStr forKey:@"ccontent"];//建议内容
        if (addMessate.length) {
            [dict setObject:addMessate forKey:@"ccontact"];//联系方式
        }
    }
//    [dict setObject:@"ec560ecc-f0de-4638-ae37-ebeaf5c8b5c2" forKey:@"cuserid"];
    [dict setObject:@(type) forKey:@"type"];
    [self request:@"/admin/productProposal.go" params:dict];
}


- (void)handleResult:(id)rootElement{
    [super handleResult:rootElement];
    NSDictionary *result = [[NSDictionary dictionaryWithDictionary:rootElement] objectForKey:@"results"];
//    if ([[NSDictionary dictionaryWithDictionary:rootElement] objectForKey:@"desc"]) {
//        NSDictionary *result = [NSDictionary dictionaryWithDictionary:rootElement];
//    }
    self.adviceItems = [SSJAdviceItem mj_objectWithKeyValues:result];
}


@end
