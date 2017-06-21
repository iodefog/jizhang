//
//  SSJChargeDetailMemberCell.h
//  SuiShouJi
//
//  Created by ricky on 16/8/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJChargeMemberItem.h"

SSJ_DEPRECATED

@interface SSJChargeDetailMemberCell : SSJBaseTableViewCell

@property(nonatomic, strong) SSJChargeMemberItem *memberItem;

@property(nonatomic, strong) NSString *memberMoney;

@end
