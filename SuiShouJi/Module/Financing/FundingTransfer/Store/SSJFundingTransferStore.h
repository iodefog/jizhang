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

/**
 *  查询转账的列表
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryForFundingTransferListWithSuccess:(void(^)(NSMutableDictionary *result))success
                                       failure:(void (^)(NSError *error))failure;

/**
 *  删除某条转账
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)deleteFundingTransferWithItem:(SSJFundingTransferDetailItem *)item
                              Success:(void(^)())success
                              failure:(void (^)(NSError *error))failure;

+ (void)saveCycleTransferRecordWithID:(NSString *)ID transferOutAccountId:(NSString *)transferOutAccountId transferInAccountId:(NSString *)transferInAccountId money:(float)money memo:(NSString *)memo

@end
