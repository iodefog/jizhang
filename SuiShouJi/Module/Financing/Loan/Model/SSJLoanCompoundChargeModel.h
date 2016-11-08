//
//  SSJLoanCompoundChargeModel.h
//  SuiShouJi
//
//  Created by old lang on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJLoanChargeModel.h"

@interface SSJLoanCompoundChargeModel : NSObject <NSCopying>

@property (nonatomic) SSJLoanType type;

//@property (nonatomic) SSJLoanCompoundChargeType chargeType;

@property (nonatomic, copy) SSJLoanChargeModel *chargeModel;

@property (nonatomic, copy) SSJLoanChargeModel *targetChargeModel;

@property (nonatomic, copy) SSJLoanChargeModel *interestCharge;

@end
