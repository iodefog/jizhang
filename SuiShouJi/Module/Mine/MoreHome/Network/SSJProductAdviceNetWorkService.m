//
//  SSJProductAdviceNetWorkService.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJProductAdviceNetWorkService.h"
#import "SSJChatMessageItem.h"
@implementation SSJProductAdviceNetWorkService
//type	int	是	0:查询 1：添加
- (void)requestAdviceMessageListWithType:(int)type{
    self.showLodingIndicator = NO;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [dict setObject:@(type) forKey:@"type"];
    [self request:@"/admin/productProposal.go" params:dict];
}


- (void)requestDidFinish:(id)rootElement{
    [super requestDidFinish:rootElement];
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:rootElement];
    self.messageItem = [SSJChatMessageItem mj_objectWithKeyValues:result];
}


@end
