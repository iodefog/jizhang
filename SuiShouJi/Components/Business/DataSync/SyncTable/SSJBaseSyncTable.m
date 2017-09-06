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

+ (NSDictionary *)fieldMapping {
    return nil;
}

+ (instancetype)table {
    return [[SSJBaseSyncTable alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.subjectToDeletion = YES;
    }
    return self;
}

- (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId
                                   inDatabase:(FMDatabase *)db
                                        error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSString *query = [NSString stringWithFormat:@"select * from %@ where iversion > %lld and cuserid = '%@'", [[self class] tableName], version, userId];
    
    FMResultSet *result = [db executeQuery:query];
    if (!result) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    while ([result next]) {
        @autoreleasepool {
            NSMutableDictionary *recordInfo = [NSMutableDictionary dictionaryWithCapacity:[[self class] columns].count];
            for (NSString *column in [[self class] columns]) {
                NSString *value = [result stringForColumn:column];
                NSString *mappedKey = [[[self class] fieldMapping] objectForKey:column];
                [recordInfo setObject:(value ?: @"") forKey:(mappedKey ?: column)];
            }
            [syncRecords addObject:recordInfo];
        }
    }
    [result close];
    
    return syncRecords;
}

- (BOOL)mergeRecords:(NSArray *)records
           forUserId:(NSString *)userId
          inDatabase:(FMDatabase *)db
               error:(NSError **)error {
    
    for (NSDictionary *record in records) {
        @autoreleasepool {
            if (![record isKindOfClass:[NSDictionary class]]) {
                if (error) {
                    *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:@"合并的数据格式错误"}];
                }
                return NO;
            }
            
            NSMutableDictionary *recordInfo = [record mutableCopy];
            NSDictionary *mapping = [[self class] fieldMapping];
            if (mapping) {
                [mapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    id value = recordInfo[obj];
                    if (value) {
                        [recordInfo removeObjectForKey:obj];
                        [recordInfo setObject:value forKey:key];
                    }
                }];
            }
            
            // 0添加  1修改  2删除
            int opertoryValue = [recordInfo[@"operatortype"] intValue];
            if (opertoryValue != 0 && opertoryValue != 1 && opertoryValue != 2) {
                continue;
            }
            
            if (![self shouldMergeRecord:recordInfo forUserId:userId inDatabase:db error:error]) {
                if (error && *error) {
                    return NO;
                }
                continue;
            }
            
            NSMutableArray *PKValues = [NSMutableArray arrayWithCapacity:[[self class] primaryKeys].count];
            for (NSString *key in [[self class] primaryKeys]) {
                id value = recordInfo[key];
                if (value) {
                    [PKValues addObject:[NSString stringWithFormat:@"%@ = '%@'", key, value]];
                }
            }
            
            if (!PKValues.count) {
                if (error) {
                    *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:@"合并的数据缺少主键"}];
                }
                return NO;
            }
            
            NSString *necessaryCondition = [PKValues componentsJoinedByString:@" and "];
            
            // 检测表中是否存在将要合并的记录
            NSString *operatorTypeStr = [db stringForQuery:[NSString stringWithFormat:@"select operatortype from %@ where %@", [[self class] tableName], necessaryCondition]];
            
            BOOL existed = NO;
            int localOperatorType = 0;
            
            if (operatorTypeStr) {
                existed = YES;
                localOperatorType = [operatorTypeStr intValue];
            }
            
            if (existed) {
                if (self.subjectToDeletion && localOperatorType == 2) {
                    continue;
                }
                
                if (![self updateRecord:recordInfo
                              condition:necessaryCondition
                              forUserId:userId
                             inDatabase:db
                                  error:error]) {
                    return NO;
                }
            } else {
                if (![self insertRecord:recordInfo
                              forUserId:userId
                             inDatabase:db
                                  error:error]) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)shouldMergeRecord:(NSDictionary *)record
                forUserId:(NSString *)userId
               inDatabase:(FMDatabase *)db
                    error:(NSError **)error {
    return YES;
}

- (BOOL)updateRecord:(NSDictionary *)record
           condition:(NSString *)condition
           forUserId:(NSString *)userId
          inDatabase:(FMDatabase *)db
               error:(NSError **)error {
    
    NSMutableString *fullCondition = [condition mutableCopy];
    if ((self.subjectToDeletion && [record[@"operatortype"] intValue] != 2) || !self.subjectToDeletion) {
        [fullCondition appendFormat:@" and cwritedate < '%@'", record[@"cwritedate"]];
    }
    
    NSMutableDictionary *mergeRecord = [NSMutableDictionary dictionary];
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:record.count];
    
    [record enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([[[self class] columns] containsObject:key]) {
            [keyValues addObject:[NSString stringWithFormat:@"%@ = :%@", key, key]];
            [mergeRecord setObject:obj forKey:key];
        }
    }];
    
    NSString *keyValuesStr = [keyValues componentsJoinedByString:@", "];
    NSString *statement = [NSString stringWithFormat:@"update %@ set %@ where %@", [[self class] tableName], keyValuesStr, fullCondition];
    
    BOOL success = [db executeUpdate:statement withParameterDictionary:mergeRecord];
    if (!success) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)insertRecord:(NSDictionary *)record
           forUserId:(NSString *)userId
          inDatabase:(FMDatabase *)db
               error:(NSError **)error {
    
    NSMutableDictionary *mergeRecord = [NSMutableDictionary dictionary];
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:[record count]];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[record count]];
    [record enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([[[self class] columns] containsObject:key]) {
            [columns addObject:key];
            [values addObject:[NSString stringWithFormat:@":%@", key]];
            [mergeRecord setObject:obj forKey:key];
        }
    }];
    
    NSString *columnsStr = [columns componentsJoinedByString:@", "];
    NSString *valuesStr = [values componentsJoinedByString:@", "];
    
    NSString *statement = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", [[self class] tableName], columnsStr, valuesStr];
    
    BOOL success = [db executeUpdate:statement withParameterDictionary:mergeRecord];
    if (!success) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)updateVersionOfRecordModifiedDuringSync:(int64_t)newVersion
                                      forUserId:(NSString *)userId
                                     inDatabase:(FMDatabase *)db
                                          error:(NSError **)error {
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
    
    NSString *update = [NSString stringWithFormat:@"update %@ set iversion = %lld where iversion >= %lld and cuserid = '%@'", [[self class] tableName], newVersion, version + 2, userId];
    BOOL success = [db executeUpdate:update];
    if (!success) {
        if (error) {
            *error = [db lastError];
        }
    }
    
    return success;
}

@end
