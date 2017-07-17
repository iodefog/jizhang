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
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"select cbillid, cuserid, cbooksid, istate, iorder, cwritedate, iversion, operatortype from bk_user_bill where cuserid = ? and iversion > ?", userId, @(version)];
    if (!resultSet) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    
    while ([resultSet next]) {
        NSString *cbillid = [resultSet stringForColumn:@"cbillid"];
        NSString *cuserid = [resultSet stringForColumn:@"cuserid"];
        NSString *cbooksid = [resultSet stringForColumn:@"cbooksid"];
        NSString *istate = [resultSet stringForColumn:@"istate"];
        NSString *iorder = [resultSet stringForColumn:@"iorder"];
        NSString *cwritedate = [resultSet stringForColumn:@"cwritedate"];
        NSString *iversion = [resultSet stringForColumn:@"iversion"];
        NSString *operatortype = [resultSet stringForColumn:@"operatortype"];
        
        [syncRecords addObject:@{@"cbillid" : cbillid ?: @"",
                                 @"cuserid" : cuserid ?: @"",
                                 @"cbooksid" : cbooksid ?: @"",
                                 @"istate" : istate ?: @"",
                                 @"iorder" : iorder ?: @"",
                                 @"cwritedate" : cwritedate ?: @"",
                                 @"iversion" : iversion ?: @"",
                                 @"operatortype" : operatortype ?: @""}];
    }
    
    return syncRecords;
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        if (![db boolForQuery:@"select count(*) from BK_USER_BILL_TYPE where CBILLID = ?", recordInfo[@"cbillid"]]) {
            continue;
        }
        
        BOOL exist = [db boolForQuery:@"select count(*) from bk_user_bill where cbillid = ? and cuserid = ? and cbooksid = ?", recordInfo[@"cbillid"], recordInfo[@"cuserid"], recordInfo[@"cbooksid"] ? : recordInfo[@"cuserid"]];
        
        if (exist) {
            if (![db executeUpdate:@"update bk_user_bill set istate = ?, iorder = ?, cwritedate = ?, iversion = ?, operatortype = ? where cbillid = ? and cuserid = ? and cbooksid = ? and cwritedate < ?", recordInfo[@"istate"], recordInfo[@"iorder"], recordInfo[@"cwritedate"], recordInfo[@"iversion"], recordInfo[@"operatortype"], recordInfo[@"cbillid"], recordInfo[@"cuserid"], recordInfo[@"cbooksid"] ? : recordInfo[@"cuserid"], recordInfo[@"cwritedate"]]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        } else {
            if (![db executeUpdate:@"insert into bk_user_bill (cbillid, cuserid, cbooksid, istate, iorder, cwritedate, iversion, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?)", recordInfo[@"cbillid"], recordInfo[@"cuserid"], recordInfo[@"cbooksid"], recordInfo[@"istate"], recordInfo[@"iorder"], recordInfo[@"cwritedate"], recordInfo[@"iversion"], recordInfo[@"operatortype"]]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        }
    }

    return YES;
}

+ (BOOL)updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:(int64_t)newVersion forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
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
    
    return [db executeUpdate:@"update bk_user_bill set iversion = ? where iversion = ? and cuserid = ?", @(newVersion), @(version + 2), userId];
}

@end
