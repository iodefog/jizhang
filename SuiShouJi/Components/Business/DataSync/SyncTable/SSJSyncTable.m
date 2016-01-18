//
//  SSJSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSyncTable.h"

int lastSyncVersion = SSJ_INVALID_SYNC_VERSION;

@implementation SSJSyncTable

+ (NSString *)tableName {
    return nil;
}

+ (NSArray *)columns {
    return nil;
}

+ (NSArray *)primaryKeys {
    return nil;
}

+ (int)lastSuccessSyncVersionInDatabase:(FMDatabase *)db {
    if (lastSyncVersion == SSJ_INVALID_SYNC_VERSION) {
        FMResultSet *lastSyncResultSet = [db executeQuery:@"select VERSION from BK_SYNC where TYPE = 1 and CUSERID =? limit 1 offset (select count(*) from BK_SYNC where TYPE = 1 and CUSERID =?)", SSJUSERID(), SSJUSERID()];
        
        if (!lastSyncResultSet) {
            SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
            return lastSyncVersion;
        }
        
        lastSyncVersion = 0;
        [lastSyncResultSet next];
        lastSyncVersion = [lastSyncResultSet intForColumnIndex:0];
    }
    return lastSyncVersion;
}

+ (NSArray *)queryRecordsForSyncInDatabase:(FMDatabase *)db {
    int lastSyncVersion = [self lastSuccessSyncVersionInDatabase:db];
    if (lastSyncVersion == SSJ_INVALID_SYNC_VERSION) {
        return nil;
    }
    
    NSMutableString *query = [NSMutableString stringWithFormat:@"select * from %@ where IVERSION > %d and CUSERID = '%@'", [self tableName], (int)lastSyncVersion, SSJUSERID()];
    NSString *additionalCondition = [self queryRecordsForSyncAdditionalCondition];
    if (additionalCondition.length) {
        [query appendFormat:@" and %@", additionalCondition];
    }
    
    FMResultSet *result = [db executeQuery:query];
    if (!result) {
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    while ([result next]) {
        NSMutableDictionary *recordInfo = [NSMutableDictionary dictionaryWithCapacity:[self columns].count];
        for (NSString *column in [self columns]) {
            [recordInfo setObject:[result stringForColumn:column] forKey:column];
        }
        [syncRecords addObject:recordInfo];
    }
    return syncRecords;
}

+ (NSString *)queryRecordsForSyncAdditionalCondition {
    return nil;
}

+ (BOOL)updateSyncVersionToServerSyncVersion:(int)version inDatabase:(FMDatabase *)db {
    int lastSyncVersion = [self lastSuccessSyncVersionInDatabase:db];
    if (lastSyncVersion == SSJ_INVALID_SYNC_VERSION) {
        return NO;
    }
    
    NSMutableString *update = [NSMutableString stringWithFormat:@"update %@ set IVERSION = %d where IVERSION > %d and CUSERID = '%@'", [self tableName], version, lastSyncVersion + 1, SSJUSERID()];
    NSString *additionalCondition = [self updateSyncVersionAdditionalCondition];
    if (additionalCondition.length) {
        [update appendFormat:@" and %@", additionalCondition];
    }
    
    BOOL success = [db executeUpdate:update];
    if (!success) {
        SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
    }
    
    return success;
}

+ (NSString *)updateSyncVersionAdditionalCondition {
    return nil;
}

+ (BOOL)mergeRecords:(NSArray *)records inDatabase:(FMDatabase *)db {
    for (NSDictionary *recordInfo in records) {
        
        if (![recordInfo isKindOfClass:[NSDictionary class]]) {
            SSJPRINT(@">>>SSJ warning: record needed to merge is not subclass of NSDictionary\n record:%@", recordInfo);
            return NO;
        }
        
        //  根据记录的操作类型，对记录进行相应的操作
        NSString *opertoryType = recordInfo[@"OPERATORTYPE"];
        if (opertoryType.length == 0) {
            SSJPRINT(@">>>SSJ warning: merge record lack of column 'OPERATORTYPE'\n record:%@", recordInfo);
            return NO;
        }
        
        //  根据表中的主键拼接合并条件
        NSString *necessaryCondition = [self primaryKeyValueConditionWithRecord:recordInfo];
        if (!necessaryCondition.length) {
            return NO;
        }
        
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select count(*) from %@ where %@", [self tableName], necessaryCondition]];
        if (!result) {
            SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
            return NO;
        }
        BOOL isRecordExist = [result intForColumnIndex:0] > 0;
        
        //  0添加  1修改  2删除
        NSMutableString *update = [NSMutableString string];
        int opertoryValue = [opertoryType intValue];
        if (opertoryValue != 0 && opertoryValue != 1 && opertoryValue != 3) {
            return NO;
        }
        
        if (isRecordExist) {
            if (opertoryValue == 1 || opertoryValue == 2) {
                NSString *updateStatement = [self updateStatementForMergeRecord:recordInfo condition:necessaryCondition];
                if (!updateStatement.length) {
                    return NO;
                }
                [update appendString:updateStatement];
            }
        } else {
            NSString *insertStatement = [self insertStatementForMergeRecord:recordInfo];
            if (!insertStatement.length) {
                return NO;
            }
            [update appendString:insertStatement];
        }
        
        NSString *additionalCondition = [self additionalConditionForMergeRecord:recordInfo];
        if (additionalCondition.length) {
            [update appendFormat:@" and %@", additionalCondition];
        }
        
        BOOL success = [db executeUpdate:update];
        if (!success) {
            SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        }
        return success;
    }
    
    SSJPRINT(@">>>SSJ warning:array records has no element\n records:%@", records);
    return YES;
}

//  根据表中的主键拼接合并条件
+ (NSString *)primaryKeyValueConditionWithRecord:(NSDictionary *)recordInfo {
    NSMutableArray *conditions = [NSMutableArray arrayWithCapacity:[self primaryKeys].count];
    for (NSString *primaryKey in [self primaryKeys]) {
        id value = recordInfo[primaryKey];
        if (!value) {
            SSJPRINT(@">>>SSJ warning: merge record lack of primary key '%@'\n record:%@", primaryKey, recordInfo);
            return nil;
        }
        
        if ([value isKindOfClass:[NSString class]]) {
            [conditions addObject:[NSString stringWithFormat:@"%@ = '%@'", primaryKey, value]];
        } else {
            [conditions addObject:[NSString stringWithFormat:@"%@ = %@", primaryKey, value]];
        }
    }
    return [conditions componentsJoinedByString:@" and "];
}

//  返回插入新纪录的sql语句
+ (NSString *)insertStatementForMergeRecord:(NSDictionary *)recordInfo {
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:[[self columns] count]];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[[self columns] count]];
    for (NSString *column in [self columns]) {
        id value = [recordInfo objectForKey:column];
        if (!value) {
            SSJPRINT(@">>>SSJ warning: merge record lack of column '%@'\n record:%@", column, recordInfo);
            return nil;
        }
        
        [columns addObject:column];
        if ([value isKindOfClass:[NSString class]]) {
            [values addObject:[NSString stringWithFormat:@"'%@'", value]];
        } else {
            [values addObject:value];
        }
    }
    
    NSString *columnsStr = [columns componentsJoinedByString:@", "];
    NSString *valuesStr = [values componentsJoinedByString:@", "];
    
    return [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", [self tableName], columnsStr, valuesStr];
}

//  返回修改的sql语句
+ (NSString *)updateStatementForMergeRecord:(NSDictionary *)recordInfo condition:(NSString *)condition {
    if (!((NSString *)recordInfo[@"cwritedate"]).length
        || !condition.length) {
        return nil;
    }
    
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:[[self columns] count]];
    for (NSString *column in [self columns]) {
        id value = [recordInfo objectForKey:column];
        if (!value) {
            SSJPRINT(@">>>SSJ warning: merge record lack of column '%@'\n record:%@", column, recordInfo);
            return nil;
        }
        
        if ([value isKindOfClass:[NSString class]]) {
            [keyValues addObject:[NSString stringWithFormat:@"%@ = '%@'", column, value]];
        } else {
            [keyValues addObject:[NSString stringWithFormat:@"%@ = %@", column, value]];
        }
    }
    NSString *keyValuesStr = [keyValues componentsJoinedByString:@", "];
    
    return [NSString stringWithFormat:@"update %@ set %@ where %@ and cwritedate < %@", [self tableName], keyValuesStr, condition, recordInfo[@"cwritedate"]];
}

+ (NSString *)additionalConditionForMergeRecord:(NSDictionary *)record {
    return nil;
}

@end
