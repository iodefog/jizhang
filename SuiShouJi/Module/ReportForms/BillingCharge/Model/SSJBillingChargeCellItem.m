//
//  SSJBillingChargeCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillingChargeCellItem.h"

@implementation SSJBillingChargeCellItem

- (id)copyWithZone:(NSZone *)zone {
    SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
    item.imageName = self.imageName;
    item.typeName = self.typeName;
    item.money = self.money;
    item.ID = self.ID;
    item.incomeOrExpence = self.incomeOrExpence;
    return item;
}

@end
