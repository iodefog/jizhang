//
//  SSJDailySumChargeTable.h
//  SuiShouJi
//
//  Created by old lang on 16/1/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FMDatabase;

SSJ_DEPRECATED

@interface SSJDailySumChargeTable : NSObject

/**
 *  更新每日流水统计表的数据
 *
 *  @param db FMDatabase实例
 *  @return 是否更新成功
 */
+ (BOOL)updateDailySumChargeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db;

@end
