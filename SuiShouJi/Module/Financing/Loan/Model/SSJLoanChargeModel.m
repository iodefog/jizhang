//
//  SSJLoanChargeModel.m
//  SuiShouJi
//
//  Created by old lang on 16/11/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanChargeModel.h"
#import "FMResultSet.h"

@implementation SSJLoanChargeModel

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJLoanChargeModel *model = [[SSJLoanChargeModel alloc] init];
    model.chargeId = self.chargeId;
    model.fundId = self.fundId;
    model.billId = self.billId;
    model.loanId = self.loanId;
    model.userId = self.userId;
    model.memo = self.memo;
    model.icon = self.icon;
    model.billDate = self.billDate;
    model.writeDate = self.writeDate;
    model.money = self.money;
    model.oldMoney = self.oldMoney;
    model.type = self.type;
    model.chargeType = self.chargeType;
    model.closedOut = self.closedOut;
    return model;   
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"chargeId":(self.chargeId ?: [NSNull null]),
                                                        @"fundId":(self.fundId ?: [NSNull null]),
                                                        @"billId":(self.billId ?: [NSNull null]),
                                                        @"loanId":(self.loanId ?: [NSNull null]),
                                                        @"userId":(self.userId ?: [NSNull null]),
                                                        @"memo":(self.memo ?: [NSNull null]),
                                                        @"icon":(self.icon ?: [NSNull null]),
                                                        @"billDate":(self.billDate ?: [NSNull null]),
                                                        @"writeDate":(self.writeDate ?: [NSNull null]),
                                                        @"money":@(self.money),
                                                        @"oldMoney":@(self.oldMoney),
                                                        @"type":@(self.type),
                                                        @"chargeType":@(self.chargeType),
                                                        @"closedOut":@(self.closedOut)}];
}

@end
