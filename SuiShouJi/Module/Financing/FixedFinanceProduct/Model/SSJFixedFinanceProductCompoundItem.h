//
//  SSJFixedFinanceProductCompoundItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJFixedFinanceProductChargeItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface SSJFixedFinanceProductCompoundItem : NSObject<NSCopying>
@property (nonatomic, copy) NSString *changeRecord;

@property (nonatomic, strong) SSJFixedFinanceProductChargeItem *chargeModel;

@property (nonatomic, strong) SSJFixedFinanceProductChargeItem *targetChargeModel;

@property (nonatomic, strong, nullable) SSJFixedFinanceProductChargeItem *interestChargeModel;

@property (nonatomic) BOOL closeOut;
@end
NS_ASSUME_NONNULL_END
