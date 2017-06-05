//
//  SSJFundingDetailHelper.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJFundingDetailListItem.h"
#import "SSJCreditCardItem.h"
#import "SSJFinancingHomeitem.h"

//  对应日期的key
extern NSString *const SSJFundingDetailDateKey;

//  对应记账流水模型的key
extern NSString *const SSJFundingDetailRecordKey;

//  对应总和的key
extern NSString *const SSJFundingDetailSumKey;


@interface SSJFundingDetailHelper : NSObject


/**
 *  获取某个资金类型的所有流水
 *
 *  @param ID      资金类型id
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryDataWithFundTypeID:(NSString *)ID
                        success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data,SSJFinancingHomeitem *fundingItem))success
                        failure:(void (^)(NSError *error))failure;

+ (void)queryDataWithCreditCardItem:(SSJCreditCardItem *)cardItem
                            success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data,SSJCreditCardItem *cardItem))success
                            failure:(void (^)(NSError *error))failure;

+ (void)queryDataWithBooksId:(NSString * )booksId
                  FundTypeID:(NSString *)ID
                     success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data))success
                     failure:(void (^)(NSError *error))failure;

+ (BOOL)queryCloseOutStateWithLoanId:(NSString *)loanId;

@end
