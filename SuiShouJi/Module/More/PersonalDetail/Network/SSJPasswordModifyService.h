//
//  SSJPasswordModifyService.h
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJPasswordModifyService : SSJBaseNetworkService
-(void)modifyPasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;
@end
