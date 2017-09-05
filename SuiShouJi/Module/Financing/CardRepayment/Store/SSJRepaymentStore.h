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
#import "SSJFinancingHomeitem.h"

@interface SSJRepaymentStore : NSObject

+ (void)saveRepaymentWithRepaymentModel:(SSJRepaymentModel *)model
                                Success:(void (^)(void))success
                                failure:(void (^)(NSError *error))failure;

+ (SSJRepaymentModel *)queryRepaymentModelWithChargeItem:(SSJBillingChargeCellItem *)item;

+ (BOOL)checkTheMoneyIsValidForTheRepaymentWithRepaymentModel:(SSJRepaymentModel *)model;

+ (void)deleteRepaymentWithRepaymentModel:(SSJRepaymentModel *)model
                                  Success:(void (^)(void))success
                                  failure:(void (^)(NSError *error))failure ;

+ (void)queryFirstRepaymentItemSuccess:(void (^)(SSJFinancingHomeitem *item))success
                               failure:(void (^)(NSError *error))failure;


+ (void)queryTheTotalExpenceForCardId:(NSString *)cardId
                       cardBillingDay:(NSInteger)billingDay
                                month:(NSDate *)currentMonth
                              Success:(void (^)(double sumMoney))success
                              failure:(void (^)(NSError *error))failure;
@end
