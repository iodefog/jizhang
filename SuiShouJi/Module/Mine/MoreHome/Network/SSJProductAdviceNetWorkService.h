//
//  SSJProductAdviceNetWorkService.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
@class SSJChatMessageItem;
@interface SSJProductAdviceNetWorkService : SSJBaseNetworkService
/**
 //type	int	是	0:查询 1：添加
 */
- (void)requestAdviceMessageListWithType:(int)type;

@property (nonatomic, strong) SSJChatMessageItem *messageItem;
@end
