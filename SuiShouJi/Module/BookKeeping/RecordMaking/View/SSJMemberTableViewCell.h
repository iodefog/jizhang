//
//  SSJMemberTableViewCell.h
//  SuiShouJi
//
//  Created by ricky on 16/10/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJChargeMemberItem.h"

@interface SSJMemberTableViewCell : SSJBaseTableViewCell

@property(nonatomic, strong) SSJChargeMemberItem *memberItem;

@property(nonatomic) BOOL selectable;

@end
