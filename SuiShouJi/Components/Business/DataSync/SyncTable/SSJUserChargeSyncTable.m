//
//  SSJUserChargeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserChargeSyncTable.h"

@implementation SSJUserChargeSyncTable

+ (NSString *)tableName {
    return @"bk_user_charge";
}

+ (NSArray *)columns {
    return @[@"ichargeid", @"imoney", @"ibillid", @"ifunsid", @"iconfigid", @"cadddate", @"ioldmoney", @"ibalance", @"cbilldate", @"cuserid", @"cimgurl", @"thumburl", @"cmemo", @"cwritedate", @"iversion", @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"ichargeid"];
}

+ (NSArray *)optionalColumns {
    return @[@"iconfigid", @"cimgurl", @"thumburl", @"cmemo"];
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError *__autoreleasing *)error {
    NSString *billId = record[@"ibillid"];
    NSString *fundId = record[@"ifunsid"];
    NSString *configId = record[@"iconfigid"];  //  定期记账配置id可已为空（仅一次）
    if (!billId || !fundId) {
        *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"ibillid and fundId in record must not be nil"}];
        SSJPRINT(@">>> SSJ warning: ibillid and fundId in record must not be nil \n record:%@", record);
        return NO;
    }
    
    //  如果此流水不依赖于特殊收支类型（istate等于2），还要从user_bill表中查询是否有此类型(因为user_bill中没有特殊收支类型)
    if ([db intForQuery:@"select istate from bk_bill_type where id = ?", billId] != 2) {
        if (![db boolForQuery:@"select count(*) from bk_user_bill where cuserid = ? and cbillid = ?", userId, billId]) {
            return NO;
        }
    }
    
    //  查询fund_info中是否有对应的资金帐户
    if (![db boolForQuery:@"select count(*) from bk_fund_info where cuserid = ? and cfundid = ?", userId, fundId]) {
        return NO;
    }
    
    //  如果返回了定期配置id，就查询定期配置表中是否有这个id
    if (configId.length) {
        //  定期配置表中没有对应id的记录
        if (![db boolForQuery:@"select count(*) from bk_charge_period_config where iconfigid = ? and cuserid = ?", configId, userId]) {
            return NO;
        }
        
        //  查询本地是否有相同configid和billdate的其它流水
        FMResultSet *resultSet = [db executeQuery:@"select ichargeid, operatortype, cwritedate from bk_user_charge where cbilldate = ? and iconfigid = ? and cuserid = ? and ichargeid <> ?", record[@"cbilldate"], record[@"iconfigid"], userId, record[@"ichargeid"]];
        if (!resultSet) {
            return NO;
        }
        
        //  本地有相同configid和billdate的流水
        while ([resultSet next]) {
            //  如果本地流水已经删除，则忽略将要合并的流水
            if ([resultSet intForColumn:@"operatortype"] == 2) {
                [resultSet close];
                return NO;
            }
            
            //  如果将要合并的流水的operatortype是2，就将本地流水的operatortype改为2，并且忽略这条记录
            if ([record[@"operatortype"] intValue] == 2) {
                [db executeUpdate:@"update bk_user_charge set operatortype = 2 where ichargeid = ?", [resultSet stringForColumn:@"ichargeid"]];
                [resultSet close];
                return NO;
            }
            
            //  本地记录修改时间晚于将要合并数据的修改时间，保留本地记录，忽略合并记录
            NSDate *localDate = [resultSet dateForColumn:@"cwritedate"];
            NSDate *mergeDate = [NSDate dateWithString:record[@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
            if ([mergeDate compare:localDate] == NSOrderedAscending) {
                [resultSet close];
                return NO;
            }
            
            //  合并数据的修改时间更晚，合并此记录，删除本地记录
            [db executeUpdate:@"update bk_user_charge set operatortype = 2 where ichargeid = ?", [resultSet stringForColumn:@"ichargeid"]];
        }
        
        [resultSet close];
    }
    
    return YES;
}

@end
