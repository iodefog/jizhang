//
//  SSJRepaymentModel.m
//  SuiShouJi
//
//  Created by ricky on 2016/11/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRepaymentModel.h"

@implementation SSJRepaymentModel

- (instancetype)copyWithZone:(NSZone *)zone {
    SSJRepaymentModel *model = [[SSJRepaymentModel alloc] init];
    model.repaymentId = _repaymentId;
    model.cardId = _cardId;
    model.cardBillingDay = _cardBillingDay;
    model.cardRepaymentDay = _cardRepaymentDay;
    model.cardName = _cardName;
    model.applyDate = _applyDate;
    model.repaymentMonth = _repaymentMonth;
    model.repaymentSourceFoundId = _repaymentSourceFoundId;
    model.repaymentSourceFoundName = _repaymentSourceFoundName;
    model.repaymentSourceFoundImage = _repaymentSourceFoundImage;
    model.repaymentMoney = _repaymentMoney;
    model.repaymentChargeId = _repaymentChargeId;
    model.sourceChargeId = _sourceChargeId;
    model.instalmentCout = _instalmentCout;
    model.currentInstalmentCout = _currentInstalmentCout;
    model.poundageRate = _poundageRate;
    model.memo = _memo;

    return model;
}

@end
