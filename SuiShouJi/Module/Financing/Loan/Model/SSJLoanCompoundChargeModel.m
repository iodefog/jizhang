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
    model.lender = self.lender;
    model.chargeModel = self.chargeModel;
    model.targetChargeModel = self.targetChargeModel;
    model.interestChargeModel = self.interestChargeModel;
    return model;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"lender":(self.lender ?: [NSNull null]),
                                                        @"chargeModel":(self.chargeModel ?: [NSNull null]),
                                                        @"targetChargeModel":(self.targetChargeModel ?: [NSNull null]),
                                                        @"interestChargeModel":(self.interestChargeModel ?: [NSNull null])}];
}

@end
