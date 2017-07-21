//
//  SSJMemberCell.h
//  SuiShouJi
//
//  Created by ricky on 16/7/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJChargeMemberItem.h"

SSJ_DEPRECATED
@interface SSJMemberCell : SSJBaseTableViewCell
@property(nonatomic, strong) SSJChargeMemberItem *item;
@end
