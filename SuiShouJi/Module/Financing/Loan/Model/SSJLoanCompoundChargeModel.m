//
//  SSJLoanCompoundChargeModel.m
//  SuiShouJi
//
//  Created by old lang on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanCompoundChargeModel.h"

@implementation SSJLoanCompoundChargeModel

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJLoanCompoundChargeModel *model = [[SSJLoanCompoundChargeModel alloc] init];
    model.type = self.type;
    model.chargeModel = self.chargeModel;
    model.targetChargeModel = self.targetChargeModel;
    model.interestCharge = self.interestCharge;
    return model;
}

@end
