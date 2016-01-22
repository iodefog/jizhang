//
//  SSJSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSyncTable.h"
#import "FMDB.h"

static NSString *const kSSJSuccessSyncVersionKey = @"kSSJSuccessSyncVersionKey";

@implementation SSJSyncTable

+ (NSCache *)memoryCache {
    static NSCache *memoryCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!memoryCache) {
            memoryCache = [[NSCache alloc] init];
        }
    });
    return memoryCache;
}

+ (int64_t)lastSuccessSyncVersionInDatabase:(FMDatabase *)db {
    
    NSNumber *versionObj = [[self memoryCache] objectForKey:kSSJSuccessSyncVersionKey];
    if (versionObj) {
        return [versionObj longLongValue];
    }
    
    FMResultSet *result = [db executeQuery:@"select count(*) from BK_SYNC"];
    if (!result) {
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return SSJ_INVALID_SYNC_VERSION;
    }
    
    if ([result intForColumnIndex:0] == 0) {
        [[self memoryCache] setObject:@(SSJDefaultSyncVersion) forKey:kSSJSuccessSyncVersionKey];
        return SSJDefaultSyncVersion;
    }
    
    result = [db executeQuery:@"select max(VERSION) from BK_SYNC where TYPE = 0 and CUSERID = ?", SSJUSERID()];
    
    if (!result) {
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return SSJ_INVALID_SYNC_VERSION;
    }
    
    [result next];
    int64_t version = [result longLongIntForColumnIndex:0];
    [[self memoryCache] setObject:@(version) forKey:kSSJSuccessSyncVersionKey];
    
    return version;
}

+ (BOOL)insertUnderwaySyncVersion:(int64_t)version inDatabase:(FMDatabase *)db {
    if ([db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values (?, 1, ?)", @(version), SSJUSERID()]) {
        return YES;
    }
    
    SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
    return NO;
}

+ (BOOL)insertSuccessSyncVersion:(int64_t)version inDatabase:(FMDatabase *)db {
    if ([db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values (?, 0, ?)", @(version), SSJUSERID()]) {
        [[self memoryCache] setObject:@(version) forKey:kSSJSuccessSyncVersionKey];
        return YES;
    }
    
    SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
    return NO;
}

@end
