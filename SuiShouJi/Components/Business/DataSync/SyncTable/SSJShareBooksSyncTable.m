//
//  SSJShareBooksSyncTable.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksSyncTable.h"
#import "SSJSyncTable.h"

@implementation SSJShareBooksSyncTable

+ (NSString *)tableName {
    return @"bk_share_books";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"cbooksid",
            @"ccreator",
            @"cadmin",
            @"cbooksname",
            @"cbookscolor",
            @"iparenttype",
            @"iversion",
            @"cwritedate",
            @"operatortype",
            @"iorder",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"cbooksid"];
}


- (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    FMResultSet *result = [db executeQuery:@"select * from bk_share_books where cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ?)", userId];
    if (!result) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    while ([result next]) {
        NSString *ID = [result stringForColumn:@"cbooksid"];
        NSString *ccreator = [result stringForColumn:@"ccreator"];
        NSString *cadmin = [result stringForColumn:@"cadmin"];
        NSString *cbooksname = [result stringForColumn:@"cbooksname"];
        NSString *cbookscolor = [result stringForColumn:@"cbookscolor"];
        NSInteger iparenttype = [result intForColumn:@"iparenttype"];
        NSString *iversion = [result stringForColumn:@"iversion"];
        NSString *cwritedate = [result stringForColumn:@"cwritedate"];
        NSInteger operatortype = [result intForColumn:@"operatortype"];
        NSInteger iorder = [result intForColumn:@"iorder"];
        [syncRecords addObject:@{@"cbooksid":ID,
                                 @"ccreator":ccreator,
                                 @"cadmin":cadmin,
                                 @"cbooksname":cbooksname,
                                 @"iparenttype":@(iparenttype),
                                 @"cbookscolor":cbookscolor,
                                 @"iversion":iversion,
                                 @"cwritedate":cwritedate,
                                 @"operatortype":@(operatortype),
                                 @"iorder":@(iorder)}];
    }
    return syncRecords;
}

- (BOOL)updateVersionOfRecordModifiedDuringSync:(int64_t)newVersion forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        if (error) {
            *error = [db lastError];
        }
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    if (newVersion == SSJ_INVALID_SYNC_VERSION) {
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    return [db executeUpdate:@"update bk_member_charge set iversion = ? where iversion = ? and ichargeid in (select cbooksid from bk_share_books_member where cmemberid = ?)", @(newVersion), @(version + 2), userId];
}
 
- (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    NSMutableArray *quitBooksArr = [NSMutableArray arrayWithCapacity:0];
    
    FMResultSet *quitBooksResult = [db executeQuery:@"select cbooksid from bk_share_books_member where cmemberid = ? and istate != ?", userId, @(SSJShareBooksMemberStateNormal)];
    
    
    if (!quitBooksResult) {
        return NO;
    }
    
    while ([quitBooksResult next]) {
        NSString *quitBookId = [quitBooksResult stringForColumn:@"cbooksid"];
        [quitBooksArr addObject:quitBookId];
    }

    for (NSDictionary *record in records) {
        if (![record isKindOfClass:[NSDictionary class]]) {
            if (error) {
                *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:@"record that is being merged is not kind of NSDictionary class"}];
            }
            SSJPRINT(@">>>SSJ warning: record needed to merge is not subclass of NSDictionary\n record:%@", record);
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
            if ([[[self class] primaryKeys] containsObject:key]) {
                [keyValues addObject:[NSString stringWithFormat:@"%@ = '%@'", key, obj]];
            }
        }];
        
        NSString *necessaryCondition = [keyValues componentsJoinedByString:@" and "];
        
        // 检测表中是否存在将要合并的记录
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select operatortype from %@ where %@", [[self class] tableName], necessaryCondition]];
        
        if (!resultSet) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        BOOL isExisted = NO;
        int localOperatorType = 0;
        NSString *statement = nil;
        NSMutableDictionary *mergeRecord = [NSMutableDictionary dictionary];
        
        while ([resultSet next]) {
            isExisted = YES;
            localOperatorType = [resultSet intForColumn:@"operatortype"];
        }
        [resultSet close];
        
        if (isExisted) {
            
            if (localOperatorType == 2) {
                continue;
            }
            
            if (localOperatorType == 0 || localOperatorType == 1) {
                //  如果将要合并的记录操作类型是删除，就不需要根据操作时间决定保留哪条记录，直接合并
                NSMutableString *condition = [necessaryCondition mutableCopy];
                if (opertoryValue == 0 || opertoryValue == 1) {
                    [condition appendFormat:@" and cwritedate < '%@'", recordInfo[@"cwritedate"]];
                }
                
                NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:recordInfo.count];
                [recordInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([[[self class] columns] containsObject:key]) {
                        [keyValues addObject:[NSString stringWithFormat:@"%@ = :%@", key, key]];
                        [mergeRecord setObject:obj forKey:key];
                    }
                }];
                NSString *keyValuesStr = [keyValues componentsJoinedByString:@", "];
                statement = [NSString stringWithFormat:@"update %@ set %@ where %@", [[self class] tableName], keyValuesStr, condition];
            }
            
        } else {
            NSMutableArray *columns = [NSMutableArray arrayWithCapacity:[recordInfo count]];
            NSMutableArray *values = [NSMutableArray arrayWithCapacity:[recordInfo count]];
            [recordInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([[[self class] columns] containsObject:key]) {
                    [columns addObject:key];
                    [values addObject:[NSString stringWithFormat:@":%@", key]];
                    [mergeRecord setObject:obj forKey:key];
                }
            }];
            
            NSString *columnsStr = [columns componentsJoinedByString:@", "];
            NSString *valuesStr = [values componentsJoinedByString:@", "];
            
            statement = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", [[self class] tableName], columnsStr, valuesStr];
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
