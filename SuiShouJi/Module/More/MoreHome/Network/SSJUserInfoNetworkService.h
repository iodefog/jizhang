//
//  SSJUserInfoNetworkService.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJUserInfoItem.h"

@interface SSJUserInfoNetworkService : SSJBaseNetworkService
@property (nonatomic,strong) SSJUserInfoItem *item;
- (void)requestUserInfo;
@end
