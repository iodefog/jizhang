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
    return @[@"ichargeid",
             @"imoney",
             @"ibillid",
             @"ifunsid",
             @"ioldmoney",
             @"ibalance",
             @"cbilldate",
             @"cuserid",
             @"cimgurl",
             @"thumburl",
             @"cmemo",
             @"cbooksid",
             @"clientadddate",
             @"cwritedate",
             @"iversion",
             @"ichargetype",
             @"cid",
             @"operatortype",
             @"cdetaildate"];
}

+ (NSArray *)primaryKeys {
    return @[@"ichargeid"];
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError *__autoreleasing *)error {
    
    if ([record[@"ichargetype"] integerValue] > SSJChargeIdTypeShareBooks) {
        return NO;
    }
    
    NSString *billId = record[@"ibillid"];
    NSString *fundId = record[@"ifunsid"];
    NSString *configId = record[@"cid"];  //  定期记账配置id可已为空（仅一次）
    SSJChargeIdType idtype = [record[@"ichargetype"] integerValue];
    if (!billId || !fundId) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"ibillid and fundId in record must not be nil"}];
        }
        SSJPRINT(@">>> SSJ warning: ibillid and fundId in record must not be nil \n record:%@", record);
        return NO;
    }
    
    //  如果返回了定期配置id，就查询定期配置表中是否有这个id
    if (configId.length && idtype == SSJChargeIdTypeCircleConfig) {
        //  定期配置表中没有对应id的记录
        if (![db boolForQuery:@"select count(*) from bk_charge_period_config where iconfigid = ? and cuserid = ?", configId, userId]) {
            return NO;
        }
        
        NSInteger operatortype = [record[@"operatortype"] integerValue];
        if (operatortype != 2) {
            //  查询本地是否有相同configid和billdate的其它有效流水
            FMResultSet *resultSet = [db executeQuery:@"select ichargeid, operatortype, cwritedate from bk_user_charge where cbilldate = ? and cid = ? and ichargetype = ? and cuserid = ? and ichargeid <> ? and operatortype <> 2", record[@"cbilldate"], record[@"cid"], @(SSJChargeIdTypeCircleConfig) , userId, record[@"ichargeid"]];
            if (!resultSet) {
                return NO;
            }
            
            //  本地有相同configid和billdate的流水
            while ([resultSet next]) {
                //  本地记录修改时间晚于将要合并数据的修改时间，保留本地记录，忽略合并记录
                NSString *localDateStr = [resultSet stringForColumn:@"cwritedate"];
                NSDate *localDate = [NSDate dateWithString:localDateStr formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
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
    }
    
    return YES;
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        
        NSMutableArray *quitBooksArr = [NSMutableArray arrayWithCapacity:0];
        
        FMResultSet *quitBooksResult = [db executeQuery:@"select cbooksid from bk_share_books_member where cmemberid = ? and istate != ?", userId, @(SSJShareBooksMemberStateNormal)];
        
        while ([quitBooksResult next]) {
            NSString *quitBookId = [quitBooksResult stringForColumn:@"cbooksid"];
            [quitBooksArr addObject:quitBookId];
        }

        
        FMResultSet *resultSet = [db executeQuery:@"select operatortype from bk_user_charge where ichargeid = ?", recordInfo[@"ichargeid"]];
        
        if (!resultSet) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        
        if (![self shouldMergeRecord:recordInfo forUserId:userId inDatabase:db error:error]) {
            if (error && *error) {
                return NO;
            }
            continue;
        }
        
        // 0添加  1修改  2删除
        int opertoryValue = [recordInfo[@"operatortype"] intValue];

        NSMutableDictionary *mergeRecord = [NSMutableDictionary dictionary];
        
        BOOL isExisted = NO;
        
        int localOperatorType = 0;
        
        NSString *statement = nil;
        
        while ([resultSet next]) {
            isExisted = YES;
            localOperatorType = [resultSet intForColumn:@"operatortype"];
        }
        
        if (isExisted) {
            if (localOperatorType == 2) {
                continue;
            }
            
            NSMutableString *condition = [NSMutableString stringWithFormat:@"ichargeid = '%@'",recordInfo[@"ichargeid"]];
            
            if (opertoryValue == 0 || opertoryValue == 1) {
                [condition appendFormat:@" and cwritedate < '%@'", recordInfo[@"cwritedate"]];
            }
            
            int chargeType = [recordInfo[@"ichargetype"] intValue];
            
            NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:recordInfo.count];
            [recordInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([[self columns] containsObject:key]) {
                    [keyValues addObject:[NSString stringWithFormat:@"%@ = :%@", key, key]];
                    [mergeRecord setObject:obj forKey:key];
                }
            }];
            NSString *keyValuesStr = [keyValues componentsJoinedByString:@", "];

            
            if (chargeType == SSJChargeIdTypeShareBooks) {
                if ([quitBooksArr containsObject:recordInfo[@"cbooksid"]] || ![recordInfo[@"cuserid"] isEqualToString:userId]) {
                    statement = [NSString stringWithFormat:@"update bk_user_charge set %@ where ichargeid = '%@'",keyValuesStr, recordInfo[@"ichargeid"]];
                } else {
                    statement = [NSString stringWithFormat:@"update bk_user_charge set %@ where %@",keyValuesStr,  condition];
                }
            } else {
                statement = [NSString stringWithFormat:@"update bk_user_charge set %@ where %@",keyValuesStr, condition];
            }
        } else {
            NSMutableArray *columns = [NSMutableArray arrayWithCapacity:[recordInfo count]];
            NSMutableArray *values = [NSMutableArray arrayWithCapacity:[recordInfo count]];
            [recordInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([[self columns] containsObject:key]) {
                    [columns addObject:key];
                    [values addObject:[NSString stringWithFormat:@":%@", key]];
                    [mergeRecord setObject:obj forKey:key];
                }
            }];
            
            NSString *columnsStr = [columns componentsJoinedByString:@", "];
            NSString *valuesStr = [values componentsJoinedByString:@", "];
            
            statement = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", [self tableName], columnsStr, valuesStr];
        }
        
        BOOL success = [db executeUpdate:statement withParameterDictionary:mergeRecord];
        if (!success) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }

        
    }
    return YES;
}

@end
