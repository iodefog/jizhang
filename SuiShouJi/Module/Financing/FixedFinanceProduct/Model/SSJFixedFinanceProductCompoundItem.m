//
//  SSJFixedFinanceProductCompoundItem.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductCompoundItem.h"
#import "SSJFixedFinanceProductChargeItem.h"

@implementation SSJFixedFinanceProductCompoundItem
- (id)copyWithZone:(nullable NSZone *)zone {
    SSJFixedFinanceProductCompoundItem *model = [[SSJFixedFinanceProductCompoundItem alloc] init];
    model.changeRecord = self.changeRecord;
    model.closeOut = self.closeOut;
    model.chargeModel = self.chargeModel;
    model.targetChargeModel = self.targetChargeModel;
    model.interestChargeModel = self.interestChargeModel;
    return model;
}

- (NSString *)debugDescription {
    return [self debugDescription];
}

//@property (nonatomic, copy) SSJFixedFinanceProductChargeItem *chargeModel;
//
//@property (nonatomic, copy) SSJFixedFinanceProductChargeItem *targetChargeModel;
//
//@property (nonatomic, copy, nullable) SSJFixedFinanceProductChargeItem *interestChargeModel;

- (void)setChargeModel:(SSJFixedFinanceProductChargeItem *)chargeModel {
    _chargeModel = chargeModel;
}

- (void)setTargetChargeModel:(SSJFixedFinanceProductChargeItem *)targetChargeModel {
    _targetChargeModel = targetChargeModel;
}

- (void)setInterestChargeModel:(SSJFixedFinanceProductChargeItem *)interestChargeModel {
    _interestChargeModel = interestChargeModel;
}

@end
