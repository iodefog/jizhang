//
//  SSJChargeMemBerItem.h
//  SuiShouJi
//
//  Created by ricky on 16/7/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJChargeMemberItem : SSJBaseCellItem

//成员名称
@property(nonatomic, strong) NSString *memberName;

//成员id
@property(nonatomic, strong) NSString *memberId;

//成员颜色
@property(nonatomic, strong) NSString *memberColor;

//成员颜色
@property(nonatomic) NSInteger memberOrder;

@end
