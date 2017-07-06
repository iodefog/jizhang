//
//  SSJSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSyncTable.h"
#import "SSJDataBaseQueue.h"

static NSString *const kSSJSuccessSyncVersionKey = @"kSSJSuccessSyncVersionKey";

@implementation SSJSyncTable

+ (int64_t)lastSuccessSyncVersionForUserId:(NSString *)userId inDatabase:(FMDatabase *)db {
    
    //  查询同步表中是否有当前用户的记录，没有就返回默认的版本号
    if (![db intForQuery:@"select count(*) from BK_SYNC where type = 0 and cuserid = ?", userId]) {
        return SSJDefaultSyncVersion;
    }
    
    //  查询同步表中最大的同步成功版本号
    FMResultSet *result = [db executeQuery:@"select max(VERSION) from BK_SYNC where TYPE = 0 and CUSERID = ?", userId];
    
    if (!result) {
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return SSJ_INVALID_SYNC_VERSION;
    }
    
    [result next];
    int64_t version = [result longLongIntForColumnIndex:0];
    [result close];
    
    return version;
}

//+ (BOOL)insertUnderwaySyncVersion:(int64_t)version forUserId:(NSString *)userId inDatabase:(FMDatabase *)db {
//    if ([db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values (?, 1, ?)", @(version), userId]) {
//        return YES;
//    }
//    
//    SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
//    return NO;
//}

+ (BOOL)insertSuccessSyncVersion:(int64_t)version forUserId:(NSString *)userId inDatabase:(FMDatabase *)db {
    if ([db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values (?, 0, ?)", @(version), userId]) {
        return YES;
    }
    
    SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
    return NO;
}

+ (BOOL)clearSyncRecordsWithUserId:(NSString *)userID {
    __block BOOL successful = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        successful = [db executeUpdate:@"delete from bk_sync where cuserid = ?", userID];
    }];
    return successful;
}

@end
