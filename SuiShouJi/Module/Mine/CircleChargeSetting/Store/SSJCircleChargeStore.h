//
//  SSJCircleChargeStore.h
//  SuiShouJi
//
//  Created by ricky on 16/5/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBillingChargeCellItem.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"

@interface SSJCircleChargeStore : NSObject
+ (void)queryForChargeListWithSuccess:(void(^)(NSArray<SSJBillingChargeCellItem *> *result))success
                              failure:(void (^)(NSError *error))failure;

+ (void)queryDefualtItemWithIncomeOrExpence:(BOOL)incomeOrExpence
                                    Success:(void(^)(SSJBillingChargeCellItem *item))success
                                    failure:(void (^)(NSError *error))failure;

+ (void)saveCircleChargeItem:(SSJBillingChargeCellItem *)item
                     success:(void(^)())success
                     failure:(void (^)(NSError *error))failure;

+ (void)getBooksForCircleChargeWithsuccess:(void (^)(NSArray *books))success failure:(void (^)(NSError *error))failure;

+ (void)getFirstBillItemForBooksId:(NSString *)booksId
                       withSuccess:(void (^)(SSJRecordMakingBillTypeSelectionCellItem *billItem))success
                           failure:(void (^)(NSError *error))failure;
@end
