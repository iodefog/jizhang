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

+ (BOOL)subjectToDeletion {
    return YES;
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    return YES;
}

+ (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSString *query = [NSString stringWithFormat:@"select * from %@ where IVERSION > %lld and CUSERID = '%@'", [self tableName], version, userId];
    
    FMResultSet *result = [db executeQuery:query];
    if (!result) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    while ([result next]) {
        NSMutableDictionary *recordInfo = [NSMutableDictionary dictionaryWithCapacity:[self columns].count];
        for (NSString *column in [self columns]) {
            NSString *value = [result stringForColumn:column];
            NSString *mappedKey = [[self fieldMapping] objectForKey:column];
            [recordInfo setObject:(value ?: @"") forKey:(mappedKey ?: column)];
        }
        [syncRecords addObject:recordInfo];
    }
    
    [result close];
    
    return syncRecords;
}

+ (BOOL)updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:(int64_t)newVersion forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    if (newVersion == SSJ_INVALID_SYNC_VERSION) {
        return NO;
    }
    
    NSString *update = [NSString stringWithFormat:@"update %@ set IVERSION = %lld where IVERSION >= %lld and CUSERID = '%@'", [self tableName], newVersion, version + 2, userId];
    BOOL success = [db executeUpdate:update];
    if (!success) {
        if (error) {
            *error = [db lastError];
        }
    }
    
    return success;
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *record in records) {
        if (![record isKindOfClass:[NSDictionary class]]) {
            if (error) {
                *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:@"合并的数据格式错误"}];
            }
            return NO;
        }
        
        NSMutableDictionary *recordInfo = [record mutableCopy];
        NSDictionary *mapping = [self fieldMapping];
        if (mapping) {
            [mapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                id value = recordInfo[obj];
                if (value) {
                    [recordInfo removeObjectForKey:obj];
                    [recordInfo setObject:value forKey:key];
                }
            }];
        }
        
        if (![self shouldMergeRecord:recordInfo forUserId:userId inDatabase:db error:error]) {
            if (error && *error) {
                return NO;
            }
            continue;
        }
        
        // 0添加  1修改  2删除
        int opertoryValue = [recordInfo[@"operatortype"] intValue];
        if (opertoryValue != 0 && opertoryValue != 1 && opertoryValue != 2) {
            continue;
        }
        
        // 根据表中的主键拼接合并条件
        NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:recordInfo.count];
        [recordInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([[self primaryKeys] containsObject:key]) {
                [keyValues addObject:[NSString stringWithFormat:@"%@ = '%@'", key, obj]];
            }
        }];
        
        NSString *necessaryCondition = [keyValues componentsJoinedByString:@" and "];
        
        // 检测表中是否存在将要合并的记录
        NSString *operatorTypeStr = [db stringForQuery:[NSString stringWithFormat:@"select operatortype from %@ where %@", [self tableName], necessaryCondition]];
        
        BOOL isExisted = NO;
        int localOperatorType = 0;
        
        if (operatorTypeStr) {
            isExisted = YES;
            localOperatorType = [operatorTypeStr intValue];
        }
        
        NSString *statement = nil;
        NSMutableDictionary *mergeRecord = [NSMutableDictionary dictionary];
        
        if (isExisted) {
            if ([self subjectToDeletion] && localOperatorType == 2) {
                continue;
            }
            
            NSMutableString *condition = [necessaryCondition mutableCopy];
            if (([self subjectToDeletion] && opertoryValue != 2) || ![self subjectToDeletion]) {
                [condition appendFormat:@" and cwritedate < '%@'", recordInfo[@"cwritedate"]];
            }
            
            NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:recordInfo.count];
            [recordInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([[self columns] containsObject:key]) {
                    [keyValues addObject:[NSString stringWithFormat:@"%@ = :%@", key, key]];
                    [mergeRecord setObject:obj forKey:key];
                }
            }];
            NSString *keyValuesStr = [keyValues componentsJoinedByString:@", "];
            statement = [NSString stringWithFormat:@"update %@ set %@ where %@", [self tableName], keyValuesStr, condition];
            
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

+ (NSDictionary *)fieldMapping {
    return nil;
}

@end
