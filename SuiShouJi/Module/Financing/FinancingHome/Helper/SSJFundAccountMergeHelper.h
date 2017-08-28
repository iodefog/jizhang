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
    SSJFundsTransferTypeAll = 0,
    SSJFundsTransferTypeNormal = 1,
    SSJFundsTransferTypeCreditCard = 2,
};

- (void)startMergeWithSourceFundId:(NSString *)sourceFundId
                      targetFundId:(NSString *)targetFundId
                      needToDelete:(BOOL)needToDelete
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure;


- (void)getFundingsWithType:(SSJFundsTransferType)fundType
               exceptFundItem:(SSJBaseCellItem *)fundItem
                      Success:(void(^)(NSArray *fundList))success
                      failure:(void (^)(NSError *error))failure;
@end
