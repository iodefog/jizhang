//
//  SSJNewMemberViewController.h
//  SuiShouJi
//
//  Created by ricky on 16/7/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJChargeMemberItem.h"

@interface SSJNewMemberViewController : SSJBaseViewController

@property(nonatomic, strong) SSJChargeMemberItem *originalItem;

@property (nonatomic, copy) void (^addNewMemberAction)(SSJChargeMemberItem *item);

@end
