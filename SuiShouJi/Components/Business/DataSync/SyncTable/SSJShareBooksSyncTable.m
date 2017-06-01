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

+ (NSArray *)columns {
    return @[@"cbooksid",
             @"ccreator",
             @"cadmin",
             @"cbooksname",
             @"cbookscolor",
             @"iparenttype",
             @"iversion",
             @"cwritedate",
             @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"cbooksid"];
}


+ (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
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
        [syncRecords addObject:@{@"cbooksid":ID,
                                 @"ccreator":ccreator,
                                 @"cadmin":cadmin,
                                 @"cbooksname":cbooksname,
                                 @"iparenttype":@(iparenttype),
                                 @"cbookscolor":cbookscolor,
                                 @"iversion":iversion,
                                 @"cwritedate":cwritedate,
                                 @"operatortype":@(operatortype)}];
    }
    return syncRecords;
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
    
    return [db executeUpdate:@"update bk_member_charge set iversion = ? where iversion = ? and ichargeid in (select cbooksid from bk_share_books_member where cmemberid = ?)", @(newVersion), @(version + 2), userId];
}

@end
