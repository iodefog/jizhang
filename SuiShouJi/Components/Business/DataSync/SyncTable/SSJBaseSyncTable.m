//
//  SSJBaseSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseSyncTable.h"
#import "SSJSyncTable.h"

@implementation SSJBaseSyncTable

+ (NSString *)tableName {
    return nil;
}

+ (NSArray *)columns {
    return nil;
}

+ (NSArray *)primaryKeys {
    return nil;
}

+ (NSArray *)optionalColumns {
    return nil;
}

+ (NSString *)queryRecordsForSyncAdditionalCondition {
    return nil;
}

+ (NSString *)updateSyncVersionAdditionalCondition {
    return nil;
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db {
    return YES;
}

+ (NSArray *)queryRecordsNeedToSyncInDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionInDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        *error = [db lastError];
        return nil;
    }
    
    NSMutableString *query = [NSMutableString stringWithFormat:@"select * from %@ where IVERSION > %lld and CUSERID = '%@'", [self tableName], version, SSJUSERID()];
    
    NSString *additionalCondition = [self queryRecordsForSyncAdditionalCondition];
    if (additionalCondition.length) {
        [query appendFormat:@" and %@", additionalCondition];
    }
    
    FMResultSet *result = [db executeQuery:query];
    if (!result) {
        *error = [db lastError];
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    while ([result next]) {
        NSMutableDictionary *recordInfo = [NSMutableDictionary dictionaryWithCapacity:[self columns].count];
        for (NSString *column in [self columns]) {
            NSString *value = [result stringForColumn:column];
            [recordInfo setObject:(value ?: @"") forKey:column];
        }
        [syncRecords addObject:recordInfo];
    }
    
    [result close];
    
    return syncRecords;
}

+ (BOOL)updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:(int64_t)newVersion inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionInDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        *error = [db lastError];
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    if (newVersion == SSJ_INVALID_SYNC_VERSION) {
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    NSMutableString *update = [NSMutableString stringWithFormat:@"update %@ set IVERSION = %lld where IVERSION > %lld and CUSERID = '%@'", [self tableName], newVersion, version + 1, SSJUSERID()];
    NSString *additionalCondition = [self updateSyncVersionAdditionalCondition];
    if (additionalCondition.length) {
        [update appendFormat:@" and %@", additionalCondition];
    }
    
    BOOL success = [db executeUpdate:update];
    if (!success) {
        *error = [db lastError];
        SSJPRINT(@">>>SSJ warning:an error occured when update sync version of record that is modified during synchronization to the newest version\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
    }
    
    return success;
}

+ (BOOL)mergeRecords:(NSArray *)records inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        if (![recordInfo isKindOfClass:[NSDictionary class]]) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"record that is being merged is not kind of NSDictionary class"}];
            SSJPRINT(@">>>SSJ warning: record needed to merge is not subclass of NSDictionary\n record:%@", recordInfo);
            return NO;
        }
        
        if (![self shouldMergeRecord:recordInfo inDatabase:db]) {
            continue;
        }
        
        //  根据合并记录返回相应的sql语句
        NSMutableString *statement = [[self sqlStatementForMergeRecord:recordInfo inDatabase:db error:error] mutableCopy];
        if (!statement) {
            return NO;
        }
        
        BOOL success = [db executeUpdate:statement];
        if (!success) {
            *error = [db lastError];
            return NO;
        }
    }
    
    return YES;
}

//  根据合并记录返回相应的sql语句
+ (NSString *)sqlStatementForMergeRecord:(NSDictionary *)recordInfo inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    //  根据记录的操作类型，对记录进行相应的操作
    NSString *opertoryType = recordInfo[@"operatortype"];
    if (opertoryType.length == 0) {
        *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"record is lack of column operatortype"}];
        SSJPRINT(@">>>SSJ warning: merge record lack of column 'OPERATORTYPE'\n record:%@", recordInfo);
        return nil;
    }
    
    //  0添加  1修改  2删除
    int opertoryValue = [opertoryType intValue];
    if (opertoryValue != 0 && opertoryValue != 1 && opertoryValue != 2) {
        *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"record has unknown operatortype value %@", opertoryType]}];
        SSJPRINT(@">>>SSJ warning:unknown OPERATORTYPE value %d", opertoryValue);
        return nil;
    }
    
    //  根据表中的主键拼接合并条件
    NSString *necessaryCondition = [self spliceKeyAndValueForKeys:[self primaryKeys] record:recordInfo joinString:@" and "];
    if (!necessaryCondition.length) {
        *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"an error occured when splice record's keys and values"}];
        SSJPRINT(@">>>SSJ warning:an error occured when splice record's keys and values");
        return nil;
    }
    
    //  检测表中是否存在将要合并的记录
    BOOL isExisted = [db boolForQuery:[NSString stringWithFormat:@"select count(*) from %@ where %@", [self tableName], necessaryCondition]];
    
    //  如果记录已存在，并且操作类型是修改（1）、删除（2），就更新记录；反之就插入记录
    NSString *statement = nil;
    
    if (isExisted) {
        NSMutableString *condition = [necessaryCondition mutableCopy];
        if (opertoryValue == 0 || opertoryValue == 1) {
            [condition appendFormat:@" and cwritedate < '%@'", recordInfo[@"cwritedate"]];
        }
        
        NSString *updateStatement = [self updateStatementForMergeRecord:recordInfo];
        
        if (updateStatement) {
            statement = [NSString stringWithFormat:@"%@ where %@", updateStatement, condition];
        }
    } else {
        statement = [self insertStatementForMergeRecord:recordInfo];
    }
    
    return statement;
}

//  返回插入新纪录的sql语句
+ (NSString *)insertStatementForMergeRecord:(NSDictionary *)recordInfo {
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:[[self columns] count]];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[[self columns] count]];
    for (NSString *column in [self columns]) {
        id value = [recordInfo objectForKey:column];
        if (!value) {
            if ([[self optionalColumns] indexOfObject:column] == NSNotFound) {
                SSJPRINT(@">>>SSJ warning: merge record lack of column '%@'\n record:%@", column, recordInfo);
                return nil;
            } else {
               continue;
            }
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

//  返回更新的sql语句
+ (NSString *)updateStatementForMergeRecord:(NSDictionary *)recordInfo {
    NSString *keyValuesStr = [self spliceKeyAndValueForKeys:[self columns] record:recordInfo joinString:@", "];
    NSMutableString *updateSql = [NSMutableString stringWithFormat:@"update %@ set %@", [self tableName], keyValuesStr];
    
    return updateSql;
}

+ (NSString *)spliceKeyAndValueForKeys:(NSArray *)keys record:(NSDictionary *)recordInfo joinString:(NSString *)joinString {
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:keys.count];
    for (NSString *key in keys) {
        id value = recordInfo[key];
        if (!value) {
            SSJPRINT(@">>>SSJ warning: splice record lack of key '%@'\n record:%@", key, recordInfo);
            continue;
        }
        
        if ([value isKindOfClass:[NSString class]]) {
            [keyValues addObject:[NSString stringWithFormat:@"%@ = '%@'", key, value]];
        } else {
            [keyValues addObject:[NSString stringWithFormat:@"%@ = %@", key, value]];
        }
    }
    return [keyValues componentsJoinedByString:joinString];
}

@end
