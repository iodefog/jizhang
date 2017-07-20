//
//  SSJFundInfoSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundInfoSyncTable.h"
#import "SSJSyncTable.h"

@implementation SSJFundInfoSyncTable

+ (NSString *)tableName {
    return @"bk_fund_info";
}

+ (NSArray *)columns {
    return @[@"cfundid",
             @"cacctname",
             @"cicoin",
             @"cparent",
             @"ccolor",
             @"cmemo",
             @"cuserid",
             @"iorder",
             @"idisplay",
             @"cwritedate",
             @"iversion",
             @"operatortype",
             @"cstartcolor",
             @"cendcolor"];
}

+ (NSArray *)primaryKeys {
    return @[@"cfundid"];
}

+ (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    FMResultSet *result = [db executeQuery:@"select * from bk_fund_info where cuserid = ? and iversion > ? and cparent <> 'root'", userId, @(version)];
    if (!result) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    while ([result next]) {
        NSString *ID = [result stringForColumn:@"cfundid"];
        NSString *cname = [result stringForColumn:@"cacctname"];
        NSString *icon = [result stringForColumn:@"cicoin"];
        NSString *parent = [result stringForColumn:@"cparent"];
        NSString *color = [result stringForColumn:@"ccolor"];
        NSString *memo = [result stringForColumn:@"cmemo"];
        NSString *userId = [result stringForColumn:@"cuserid"];
        NSString *order = [result stringForColumn:@"iorder"];
        NSString *display = [result stringForColumn:@"idisplay"];
        NSString *startColor = [result stringForColumn:@"cstartcolor"];
        NSString *endColor = [result stringForColumn:@"cendcolor"];
        NSString *writeDate = [result stringForColumn:@"cwritedate"];
        NSString *version = [result stringForColumn:@"iversion"];
        NSString *operatorType = [result stringForColumn:@"operatortype"];
        
        [syncRecords addObject:@{@"cfundid":ID ?: @"",
                                 @"cacctname":cname ?: @"",
                                 @"cicoin":icon ?: @"",
                                 @"cparent":parent ?: @"",
                                 @"ccolor":color ?: @"",
                                 @"cmemo":memo ?: @"",
                                 @"cuserid":userId ?: @"",
                                 @"iorder":order ?: @"",
                                 @"idisplay":display ?: @"",
                                 @"cstartcolor":startColor ?: @"",
                                 @"cendcolor":endColor ?: @"",
                                 @"cwritedate":writeDate ?: @"",
                                 @"iversion":version ?: @"",
                                 @"operatortype":operatorType ?: @""}];
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
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    if (newVersion == SSJ_INVALID_SYNC_VERSION) {
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    BOOL success = [db executeUpdate:@"update bk_fund_info set iversion = ? where iversion = ? and cuserid = ? and cparent <> 'root'", @(newVersion), @(version + 2), userId];
    if (!success) {
        if (error) {
            *error = [db lastError];
        }
    }
    
    return success;
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    return [db boolForQuery:@"select count(*) from BK_FUND_INFO where CFUNDID = ?", record[@"cparent"]];
}

@end
