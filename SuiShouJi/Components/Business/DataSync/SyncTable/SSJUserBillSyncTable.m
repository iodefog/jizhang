//
//  SSJUserBillSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserBillSyncTable.h"
#import "SSJSyncTable.h"

@implementation SSJUserBillSyncTable

+ (NSString *)tableName {
    return @"bk_user_bill";
}

+ (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        *error = [db lastError];
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"select cbillid, cuserid, istate, iorder, cwritedate, iversion, operatortype from bk_user_bill where cuserid = ? and iversion > ?", userId, @(version)];
    if (!resultSet) {
        *error = [db lastError];
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    
    while ([resultSet next]) {
        NSString *cbillid = [resultSet stringForColumn:@"cbillid"];
        NSString *cuserid = [resultSet stringForColumn:@"cuserid"];
        NSString *istate = [resultSet stringForColumn:@"istate"];
        NSString *iorder = [resultSet stringForColumn:@"iorder"];
        NSString *cwritedate = [resultSet stringForColumn:@"cwritedate"];
        NSString *iversion = [resultSet stringForColumn:@"iversion"];
        NSString *operatortype = [resultSet stringForColumn:@"operatortype"];
        
        [syncRecords addObject:@{cbillid : cbillid ?: @"",
                                 cuserid : cuserid ?: @"",
                                 istate : istate ?: @"",
                                 iorder : iorder ?: @"",
                                 cwritedate : cwritedate ?: @"",
                                 iversion : iversion ?: @"",
                                 operatortype : operatortype ?: @""}];
    }
    
    return syncRecords;
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        if (![db boolForQuery:@"select count(*) from BK_BILL_TYPE where ID = ?", recordInfo[@"cbillid"]]) {
            continue;
        }
        
        BOOL exist = [db boolForQuery:@"select count(*) from bk_user_bill where cbillid = ? and cuserid = ?", recordInfo[@"cbillid"], recordInfo[@"cuserid"]];
        
        if (exist) {
            if (![db executeUpdate:@"update bk_user_bill set istate = :istate, iorder = :iorder, cwritedate = :cwritedate, iversion = :iversion, operatortype = :operatortype where cbillid = :cbillid and cuserid = :cuserid and cwritedate < :cwritedate" withParameterDictionary:recordInfo]) {
                *error = [db lastError];
                return NO;
            }
        } else {
            if (![db executeUpdate:@"insert into bk_user_bill (cbillid, cuserid, istate, iorder, cwritedate, iversion, operatortype) values (:cbillid, :cuserid, :istate, :iorder, :cwritedate, :iversion, :operatortype)" withParameterDictionary:recordInfo]) {
                *error = [db lastError];
                return NO;
            }
        }
    }
    
    return YES;
}

+ (BOOL)updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:(int64_t)newVersion forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        *error = [db lastError];
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    if (newVersion == SSJ_INVALID_SYNC_VERSION) {
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    return [db executeUpdate:@"update bk_user_bill set iversion = ? where iversion = ? and cuserid = ?", @(newVersion), @(version + 2), userId];
}

@end
