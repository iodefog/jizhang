//
//  SSJFundAccountMergeHelper.h
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBaseCellItem.h"

@interface SSJFundAccountMergeHelper : NSObject
// 类型,1是转入.0是转出
typedef NS_ENUM(NSInteger, SSJFundsTransferType) {
    SSJFundsTransferTypeNormal = 0,
    SSJFundsTransferTypeCreditCard = 1,
    SSJFundsTransferTypeAll = 2
};

- (void)startMergeWithSourceFundId:(NSString *)sourceFundId
                      targetFundId:(NSString *)targetFundId
                      needToDelete:(BOOL)needToDelete
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure;

/**
 获取所有的资金帐户

 @param fundType 资金账户类型,0为普通资金帐户,1为信用卡或者蚂蚁花呗
 @return 所有得资金帐户
 */
- (NSArray *)getFundingsWithType:(SSJFundsTransferType)fundType exceptFundItem:(SSJBaseCellItem *)fundItem;

@end
