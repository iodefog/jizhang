//
//  SSJShareBooksMemberSyncTable.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMemberSyncTable.h"
#import "SSJSyncTable.h"

@implementation SSJShareBooksMemberSyncTable

+ (NSString *)tableName {
    return @"bk_share_books_member";
}

+ (NSArray *)columns {
    return @[@"cmemberid",
             @"cbooksid",
             @"cjoindate",
             @"istate",
             @"cicon"];
}

+ (NSArray *)primaryKeys {
    return @[@"cmemberid",@"cbooksid"];
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        BOOL exist = [db boolForQuery:@"select count(*) from bk_share_books_member where cmemberid = ? and cbooksid = ?", recordInfo[@"cmemberid"], recordInfo[@"cbooksid"]];

        
        if (exist) {
            if (![db executeUpdate:@"update bk_share_books_member set cjoindate = ? ,istate = ? ,cicon = ? where cbooksid = ? and cmemberid = ?", recordInfo[@"cjoindate"], recordInfo[@"istate"], recordInfo[@"cicon"], recordInfo[@"cbooksid"], recordInfo[@"cmemberid"]]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        } else {
            if (![db executeUpdate:@"inset into bk_share_books_member (cjoindate,istate,cicon,cbooksid,cmemberid) values (?,?,?,?,?)", recordInfo[@"cjoindate"], recordInfo[@"istate"], recordInfo[@"cicon"], recordInfo[@"cbooksid"], recordInfo[@"cmemberid"]]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        }
    }
    
    return YES;
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

@end
