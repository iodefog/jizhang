//
//  SSJFundAccountTable.h
//  SuiShouJi
//
//  Created by old lang on 16/1/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface SSJFundAccountTable : NSObject

/**
 *  更新资金帐户金额表中当前用户的余额
 *
 *  @param db FMDatabase实例
 *  @return 是否更新成功
 */
+ (BOOL)updateBalanceInDatabase:(FMDatabase *)db;

@end
