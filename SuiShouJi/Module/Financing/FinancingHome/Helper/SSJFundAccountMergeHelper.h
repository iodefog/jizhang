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
- (NSArray *)getFundingsWithType:(BOOL)fundType exceptFundItem:(SSJBaseCellItem *)fundItem;

@end
