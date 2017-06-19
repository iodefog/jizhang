//
//  SSJInviteCodeJoinViewController.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJInviteCodeJoinViewController : SSJBaseViewController

@property (nonatomic, copy) void (^inviteCodeJoinBooksBlock)(NSString *bookName);

@property(nonatomic, strong) NSString *inviteCode;

@end
