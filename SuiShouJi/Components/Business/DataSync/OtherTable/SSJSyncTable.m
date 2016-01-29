//
//  SSJSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSyncTable.h"
#import "FMDB.h"
#import "SSJDataSyncHelper.h"

static NSString *const kSSJSuccessSyncVersionKey = @"kSSJSuccessSyncVersionKey";

@implementation SSJSyncTable

//+ (NSCache *)memoryCache {
//    static NSCache *memoryCache = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (!memoryCache) {
//            memoryCache = [[NSCache alloc] init];
//        }
//    });
//    return memoryCache;
//}

+ (int64_t)lastSuccessSyncVersionInDatabase:(FMDatabase *)db {
    
//    NSNumber *versionObj = [[self memoryCache] objectForKey:kSSJSuccessSyncVersionKey];
//    if (versionObj) {
//        return [versionObj longLongValue];
//    }
    
    //  查询同步表中是否有当前用户的记录，没有就返回默认的版本号
    if (![db intForQuery:@"select count(*) from BK_SYNC where type = 0 and cuserid = ?", SSJCurrentSyncUserId()]) {
//        [[self memoryCache] setObject:@(SSJDefaultSyncVersion) forKey:kSSJSuccessSyncVersionKey];
        return SSJDefaultSyncVersion;
    }
    
    //  查询同步表中最大的同步成功版本号
    FMResultSet *result = [db executeQuery:@"select max(VERSION) from BK_SYNC where TYPE = 0 and CUSERID = ?", SSJCurrentSyncUserId()];
    
    if (!result) {
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return SSJ_INVALID_SYNC_VERSION;
    }
    
    [result next];
    int64_t version = [result longLongIntForColumnIndex:0];
//    [[self memoryCache] setObject:@(version) forKey:kSSJSuccessSyncVersionKey];
    
    [result close];
    
    return version;
}

+ (BOOL)insertUnderwaySyncVersion:(int64_t)version inDatabase:(FMDatabase *)db {
    if ([db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values (?, 1, ?)", @(version), SSJCurrentSyncUserId()]) {
        return YES;
    }
    
    SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
    return NO;
}

+ (BOOL)insertSuccessSyncVersion:(int64_t)version inDatabase:(FMDatabase *)db {
    if ([db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values (?, 0, ?)", @(version), SSJCurrentSyncUserId()]) {
//        [[self memoryCache] setObject:@(version) forKey:kSSJSuccessSyncVersionKey];
        return YES;
    }
    
    SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
    return NO;
}

@end
