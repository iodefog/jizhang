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

@interface SSJCreditCardStore : NSObject

+ (SSJCreditCardItem *)queryCreditCardDetailWithCardId:(NSString *)cardId;

+ (NSError *)saveCreditCardWithCardItem:(SSJCreditCardItem *)item
                             inDatabase:(FMDatabase *)db;

+ (void)deleteCreditCardWithCardItem:(SSJCreditCardItem *)item
                             Success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure;

+ (float)queryCreditCardBalanceForTheMonth:(NSInteger)month billingDay:(NSInteger)billingDay WithCardId:(NSString *)cardId;

+ (void)saveCreditCardWithCardItem:(SSJCreditCardItem *)item
                        remindItem:(SSJReminderItem *)remindItem
                           Success:(void (^)(void))success
                           failure:(void (^)(NSError *error))failure;
@end
