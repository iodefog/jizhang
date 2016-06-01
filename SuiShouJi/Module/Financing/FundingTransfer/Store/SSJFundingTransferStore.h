//
//  SSJFundingTransferListStore.h
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJFundingTransferDetailItem.h"

@interface SSJFundingTransferStore : NSObject
+ (void)queryForFundingTransferListWithSuccess:(void(^)(NSMutableDictionary *result))success
                                       failure:(void (^)(NSError *error))failure;

+ (void)deleteFundingTransferWithItem:(SSJFundingTransferDetailItem *)item
                              Success:(void(^)())success
                              failure:(void (^)(NSError *error))failure;
@end
