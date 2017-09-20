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
    item.editeDate = self.editeDate;
    item.billId = self.billId;
    item.chargeImage = self.chargeImage;
    item.chargeThumbImage = self.chargeThumbImage;
    item.booksId = self.booksId;
    item.booksName = self.booksName;
    item.chargeCircleType = self.chargeCircleType;
    item.chargeCircleEndDate = self.chargeCircleEndDate;
    item.isOnOrNot = self.isOnOrNot;
    item.chargeIndex = self.chargeIndex;
    item.operatorType = self.operatorType;
    item.transferSource = self.transferSource;
    item.membersItem = self.membersItem;
    item.newlyAddMembers = self.newlyAddMembers;
    item.deletedMembers = self.deletedMembers;
    item.loanChargeType = self.loanChargeType;
    item.loanType = self.loanType;
    item.loanOrFixedSource = self.loanOrFixedSource;
    item.clientAddDate = self.clientAddDate;
    item.idType = self.idType;
    item.sundryId = self.sundryId;
    

    return item;
}

@end
