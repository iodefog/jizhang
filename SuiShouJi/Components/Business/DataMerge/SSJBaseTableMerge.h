//
//  SSJBaseTableMerge.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface SSJBaseTableMerge : NSObject

+ (NSString *)tableName;

+ (NSArray *)columns;

+ (NSArray *)primaryKeys;


+ (NSDictionary *)queryDatasWithSourceUserId:(NSString *)sourceUserid
                                TargetUserId:(NSString *)targetUserId
                                    FromDate:(NSDate *)fromDate
                                      ToDate:(NSDate *)toDate
                                  inDataBase:(FMDatabase *)db;

+ (void)updateIdSourceUserId:(NSString *)sourceUserid
                TargetUserId:(NSString *)targetUserId
                     DataDic:(NSDictionary *)dic;

+ (NSDictionary *)queryUserChargeWithUserId:(NSString *)userId
                                  condition:(NSString *)condition
                                   FromDate:(NSDate *)fromDate
                                     ToDate:(NSDate *)toDate
                                 inDataBase:(FMDatabase *)db;

@end
