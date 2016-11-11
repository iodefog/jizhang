//
//  SSJLoanCompoundChargeModel.h
//  SuiShouJi
//
//  Created by old lang on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJLoanChargeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJLoanCompoundChargeModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *lender;

@property (nonatomic) BOOL closeOut;

@property (nonatomic, copy) SSJLoanChargeModel *chargeModel;

@property (nonatomic, copy) SSJLoanChargeModel *targetChargeModel;

@property (nonatomic, copy, nullable) SSJLoanChargeModel *interestChargeModel;

@end

NS_ASSUME_NONNULL_END
