//
//  SSJBillTypeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/5/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillTypeSyncTable.h"
#import "SSJSyncTable.h"

@implementation SSJBillTypeSyncTable

+ (NSString *)tableName {
    return @"bk_bill_type";
}

+ (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    FMResultSet *result = [db executeQuery:@"select a.id, a.cname, a.itype, a.ccoin, a.ccolor, a.icustom, a.istate from bk_bill_type as a, bk_user_bill as b where a.id = b.cbillid and a.icustom = 1 and b.cuserid = ? and b.iversion > ?", userId, @(version)];
    if (!result) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    while ([result next]) {
        NSString *ID = [result stringForColumn:@"id"];
        NSString *cname = [result stringForColumn:@"cname"];
        NSString *itype = [result stringForColumn:@"itype"];
        NSString *ccoin = [result stringForColumn:@"ccoin"];
        NSString *ccolor = [result stringForColumn:@"ccolor"];
        NSString *icustom = [result stringForColumn:@"icustom"];
        NSString *istate = [result stringForColumn:@"istate"];
        [syncRecords addObject:@{@"id":ID,
                                 @"cname":cname,
                                 @"itype":itype,
                                 @"ccoin":ccoin,
                                 @"ccolor":ccolor,
                                 @"icustom":icustom,
                                 @"istate":istate}];
    }
    return syncRecords;
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        NSString *ID = recordInfo[@"id"];
        NSString *cname = recordInfo[@"cname"];
        NSString *itype = recordInfo[@"itype"];
        NSString *ccoin = recordInfo[@"ccoin"];
        NSString *ccolor = recordInfo[@"ccolor"];
        NSString *custom = recordInfo[@"icustom"];
        NSString *state = recordInfo[@"istate"];
        if (![db executeUpdate:@"replace into bk_bill_type (id, cname, itype, ccoin, ccolor, icustom, istate) values (?, ?, ?, ?, ?, ?, ?)", ID, cname, itype, ccoin, ccolor, custom, state]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    return YES;
}

+ (BOOL)updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:(int64_t)newVersion forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    // 因为自定义类别不能修改，这里什么都不用做
    return YES;
}

@end
