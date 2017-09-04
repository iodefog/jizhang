//
//  SSJCreditCardStore.h
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJCreditCardItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJReminderItem.h"
#import "SSJFinancingHomeitem.h"

@interface SSJCreditCardStore : NSObject

+ (NSError *)saveCreditCardWithCardItem:(SSJCreditCardItem *)item
                             inDatabase:(FMDatabase *)db;

+ (float)queryCreditCardBalanceForTheMonth:(NSInteger)month billingDay:(NSInteger)billingDay WithCardId:(NSString *)cardId;

+ (void)saveCreditCardWithCardItem:(SSJCreditCardItem *)item
                        remindItem:(SSJReminderItem *)remindItem
                           Success:(void (^)(NSInteger operatortype))success
                           failure:(void (^)(NSError *error))failure ;

+ (BOOL)deleteCreditCardWithCardItem:(SSJFinancingHomeitem *)item
                          inDatabase:(FMDatabase *)db
                           forUserId:(NSString *)userId
                               error:(NSError **)error;

+ (void)queryTheTotalExpenceForCardId:(NSString *)cardId
                       cardBillingDay:(NSInteger)billingDay
                                month:(NSDate *)currentMonth
                              Success:(void (^)(double sumMoney))success
                              failure:(void (^)(NSError *error))failure;
@end
