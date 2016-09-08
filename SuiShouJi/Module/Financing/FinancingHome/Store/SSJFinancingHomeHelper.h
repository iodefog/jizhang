//
//  SSJFinancingHomeHelper.h
//  SuiShouJi
//
//  Created by ricky on 16/3/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJFinancingHomeitem.h"

@interface SSJFinancingHomeHelper : NSObject
/**
 *  查询所有的资金列表
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryForFundingListWithSuccess:(void(^)(NSArray<SSJFinancingHomeitem *> *result))success failure:(void (^)(NSError *error))failure;

/**
 *  查询所有资金的总额
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryForFundingSumMoney:(void(^)(double result))success failure:(void (^)(NSError *error))failure;

+ (void)SaveFundingOderWithItems:(NSArray <SSJFinancingHomeitem *> *)items error:(NSError **)error;

+ (BOOL)deleteFundingWithFundingItem:(SSJFinancingHomeitem *)item;
@end
