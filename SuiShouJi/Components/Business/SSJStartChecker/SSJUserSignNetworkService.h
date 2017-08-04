//
//  SSJUserSignNetworkService.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJStartLunchItem.h"

@interface SSJUserSignNetworkService : SSJBaseNetworkService


//启动页模型
@property (nonatomic, strong) SSJStartLunchItem *statrLunchItem;

/**
 请求启动页
 @param startVer 	客户端配置版本
 */
- (void)requestUserSign;
@end
