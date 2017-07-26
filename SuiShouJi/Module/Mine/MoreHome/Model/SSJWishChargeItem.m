//
//  SSJWishChargeItem.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishChargeItem.h"

@implementation SSJWishChargeItem
- (id)copyWithZone:(NSZone *)zone {
    SSJWishChargeItem *item = [[SSJWishChargeItem alloc] init];
    item.chargeId = self.chargeId;
    item.money = self.money;
    item.wishId = self.wishId;
    item.iversion = self.iversion;
    item.memo = self.memo;
    item.cuserId = self.cuserId;
    item.itype = self.itype;
    item.cbillDate = self.cbillDate;
    item.remindDate = self.remindDate;
    item.remindDateStr = self.remindDateStr;
    item.wishChargeType = self.wishChargeType;
    return item;
}
@end
