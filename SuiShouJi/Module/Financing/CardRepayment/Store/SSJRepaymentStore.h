//
//  SSJRepaymentStore.h
//  SuiShouJi
//
//  Created by ricky on 2016/11/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJRepaymentModel.h"
#import "SSJBillingChargeCellItem.h"

@interface SSJRepaymentStore : NSObject

+ (void)saveRepaymentWithRepaymentModel:(SSJRepaymentModel *)model
                                Success:(void (^)(void))success
                                failure:(void (^)(NSError *error))failure;

+ (SSJRepaymentModel *)queryRepaymentModelWithChargeItem:(SSJBillingChargeCellItem *)item;

+ (BOOL)checkTheMoneyIsValidForTheRepaymentWithRepaymentModel:(SSJRepaymentModel *)model;

+ (void)deleteRepaymentWithRepaymentModel:(SSJRepaymentModel *)model
                                  Success:(void (^)(void))success
                                  failure:(void (^)(NSError *error))failure ;

@end
