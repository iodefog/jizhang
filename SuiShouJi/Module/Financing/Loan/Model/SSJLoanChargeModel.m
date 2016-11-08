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
    model.money = self.money;
    model.billDate = self.billDate;
    model.memo = self.memo;
    model.type = self.type;
    model.chargeType = self.chargeType;
    return model;   
}

@end
