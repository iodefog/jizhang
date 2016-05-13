//
//  SSJBookkeepingTreeCheckInModel.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeCheckInModel.h"

@implementation SSJBookkeepingTreeCheckInModel

+ (void)load {
    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"checkInTimes":@"isignin",
                 @"lastCheckInDate":@"isignindate",  // 第三方登录时，服务器返回的crealname就是用户昵称
                 @"userId":@"cuserid",
                 @"treeImgUrl":@"treeImgUrl",
                 @"treeGifUrl":@"treeGifUrl",
                 @"hasShaked":@"hasShaked"};
    }];
}

@end
