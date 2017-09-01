//
//  SSJMemberChargeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/7/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberChargeSyncTable.h"
#import "SSJSyncTable.h"

@implementation SSJMemberChargeSyncTable

+ (NSString *)tableName {
    return @"bk_member_charge";
}

- (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    FMResultSet *result = [db executeQuery:@"select a.ichargeid, a.cmemberid, a.imoney, a.iversion, a.cwritedate, a.operatortype from bk_member_charge as a, bk_user_charge as b where a.ichargeid = b.ichargeid and b.cuserid = ? and a.iversion > ?", userId, @(version)];
    if (!result) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    
    while ([result next]) {
        NSString *chargeID = [result stringForColumn:@"ichargeid"];
        NSString *memberID = [result stringForColumn:@"cmemberid"];
        NSString *money = [result stringForColumn:@"imoney"];
        NSString *version = [result stringForColumn:@"iversion"];
        NSString *writeDate = [result stringForColumn:@"cwritedate"];
        NSString *operatortype = [result stringForColumn:@"operatortype"];
        
        [syncRecords addObject:@{@"ichargeid":chargeID,
                                 @"cmemberid":memberID,
                                 @"imoney":money,
                                 @"iversion":version,
                                 @"cwritedate":writeDate,
                                 @"operatortype":operatortype}];
    }
    
    return syncRecords;
}

- (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    // 提取端返回的数据中所有的chargeid，删除所有和该chargeid相关的成员流水记录删除，再逐条插入返回的数据
    NSMutableArray *chargeIds = [NSMutableArray array];
    for (NSDictionary *recordInfo in records) {
        NSString *chargeId = recordInfo[@"ichargeid"];
        if (!chargeId) {
            continue;
        }
        
        NSString *tmpChargeId = [NSString stringWithFormat:@"'%@'", chargeId];
        if (![chargeIds containsObject:tmpChargeId]) {
            [chargeIds addObject:tmpChargeId];
        }
    }
    
    NSString *chargeIdStr = [chargeIds componentsJoinedByString:@","];
    NSString *deleteStr = [NSString stringWithFormat:@"delete from bk_member_charge where ichargeid in (%@)", chargeIdStr];
    if (![db executeUpdate:deleteStr]) {
        return NO;
    }
    
    for (NSDictionary *recordInfo in records) {
        NSString *chargeID = recordInfo[@"ichargeid"];
        NSString *memberID = recordInfo[@"cmemberid"];
        NSString *money = recordInfo[@"imoney"];
        NSString *version = recordInfo[@"iversion"];
        NSString *writeDate = recordInfo[@"cwritedate"];
        NSString *operatortype = recordInfo[@"operatortype"];
        
        if (![db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) values(?, ?, ?, ?, ?, ?)", chargeID, memberID, money, version, writeDate, operatortype]) {
            return NO;
        }
    }
    
    return YES;
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
    
    return [db executeUpdate:@"update bk_member_charge set iversion = ? where iversion = ? and ichargeid in (select ichargeid from bk_user_charge where cuserid = ?)", @(newVersion), @(version + 2), userId];
}

@end
