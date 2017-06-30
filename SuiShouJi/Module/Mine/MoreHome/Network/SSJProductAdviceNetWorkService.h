//
//  SSJProductAdviceNetWorkService.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

typedef NS_ENUM(NSUInteger, SSJAdviceType) {
    SSJAdviceTypeAdvice,//产品建议
    SSJAdviceTypeFault,//使用故障
    SSJAdviceTypeTuCao,//我要吐槽
};

@class SSJChatMessageItem,SSJAdviceItem;


@interface SSJProductAdviceNetWorkService : SSJBaseNetworkService

- (void)requestAdviceMessageListWithType:(SSJAdviceType)type message:(NSString *)messageStr additionalMessage:(NSString *)addMessate;

- (void)requestQQDetail;

@end
