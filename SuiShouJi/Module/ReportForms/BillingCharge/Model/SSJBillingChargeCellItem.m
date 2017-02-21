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
    item.configId = self.configId;
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
    item.loanId = self.loanId;
    item.loanChargeType = self.loanChargeType;
    item.loanType = self.loanType;
    item.loanSource = self.loanSource;
    item.clientAddDate = self.clientAddDate;
    item.idType = self.idType;
    item.sundryId = self.sundryId;

    return item;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"imageName":(_imageName ?: [NSNull null]),
                                                       @"typeName":(_typeName ?: [NSNull null]),
                                                       @"money":(_money ?: [NSNull null]),
                                                       @"colorValue":(_colorValue ?: [NSNull null]),
                                                       @"ID":(_ID ?: [NSNull null]),
                                                       @"incomeOrExpence":@(_incomeOrExpence),
                                                       @"billDate":(_billDate ?: [NSNull null]),
                                                       @"fundId":(_fundId ?: [NSNull null]),
                                                       @"fundName":(_fundName ?: [NSNull null]),
                                                       @"fundImage":(_fundImage ?: [NSNull null]),
                                                       @"fundOperatorType":@(_fundOperatorType),
                                                       @"editeDate":(_editeDate ?: [NSNull null]),
                                                       @"billId":(_billId ?: [NSNull null]),
                                                       @"chargeMemo":(_chargeMemo ?: [NSNull null]),
                                                       @"chargeImage":(_chargeImage ?: [NSNull null]),
                                                       @"chargeThumbImage":(_chargeThumbImage ?: [NSNull null]),
                                                       @"configId":(_configId ?: [NSNull null]),
                                                       @"booksId":(_booksId ?: [NSNull null]),
                                                       @"booksName":(_booksName ?: [NSNull null]),
                                                       @"chargeCircleType":@(_chargeCircleType),
                                                       @"isOnOrNot":@(_isOnOrNot),
                                                       @"chargeIndex":_chargeIndex,
                                                       @"operatorType":@(_operatorType),
                                                       @"transferSource":(_transferSource ?: [NSNull null]),
                                                       @"membersItem":(_membersItem ?: [NSNull null]),
                                                       @"newlyAddMembers":(_newlyAddMembers ?: [NSNull null]),
                                                       @"deletedMembers":(_deletedMembers ?: [NSNull null])}];
}

@end
