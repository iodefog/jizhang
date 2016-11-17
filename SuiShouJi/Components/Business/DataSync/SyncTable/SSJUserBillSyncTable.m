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
        if (![db boolForQuery:@"select count(*) from BK_BILL_TYPE where ID = ?", recordInfo[@"cbillid"]]) {
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

+ (BOOL)mergeWhenLoginWithRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    BOOL hasUpdated = NO;
    for (NSDictionary *recordInfo in records) {
        if ([recordInfo[@"cbillid"] isEqualToString:@"1072"] || [recordInfo[@"cbillid"] isEqualToString:@"2046"]) {
            hasUpdated = YES;
            break;
        }
    }
    // 首先判断本地有没有用户的数据
    if (![db intForQuery:@"select count(1) from bk_user_bill where cuserid = ?",userId]) {
        // 如果本地没有该用户数据,则首先把后端的数据插入表中
        for (NSDictionary *recordInfo in records) {
            NSString *sql = [NSString stringWithFormat:@"insert into bk_user_bill (cbillid, cuserid, istate, iorder, cwritedate, iversion, operatortype, cbooksid) values ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", recordInfo[@"cbillid"], recordInfo[@"cuserid"], recordInfo[@"istate"], recordInfo[@"iorder"], recordInfo[@"cwritedate"], recordInfo[@"iversion"], recordInfo[@"operatortype"],recordInfo[@"cbooksid"] ? : recordInfo[@"cuserid"]];
            if (![db executeUpdate:sql]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        }
        // 然后将所有cbooksid为null的账户类型改为日常账本
        if (![db executeUpdate:@"update bk_user_bill set cbooksid = ? where cuserid = ? and cbooksid is null",userId,userId]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        // 如果后端数据没有升级的话要对后端数据进行处理
        if (!hasUpdated) {
            NSString *sql1 = [NSString stringWithFormat:@"insert into bk_user_bill select ub.cuserid, ub.cbillid, ub.istate, '%@', '%@', 1, ub.iorder, bk.cbooksid from bk_user_bill ub , bk_books_type bk where ub.operatortype <> 2 and bk.cbooksid not like bk.cuserid || '%%' and ub.cbooksid = bk.cuserid and length(ub.cbillid) < 10  and bk.cuserid = '%@' and ub.cuserid = '%@'",writeDate,@(SSJSyncVersion()),userId,userId];
            // 然后将日常账本的记账类型拷进自定义账本
            if (![db executeUpdate:sql1]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
            
            // 将四个非日常账本的默认账本插入所有默认类型
            NSString *sql2 = [NSString stringWithFormat:@"insert into bk_user_bill select a.cuserid ,b.id , 1, '%@', '%@', 0, b.defaultorder, a.cbooksid from bk_books_type a, bk_bill_type b where a.iparenttype = b.ibookstype and a.cbooksid <> a.cuserid and length(b.ibookstype) = 1 and a.cbooksid like a.cuserid || '%%' and cuserid = '%@'",writeDate,@(SSJSyncVersion()),userId];
            if (![db executeUpdate:sql2]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
            
            FMResultSet *result = [db executeQuery:@"select id ,defaultorder ,ibookstype from bk_bill_type where length(ibookstype) > 1"];
            
            NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
            
            while ([result next]) {
                NSString *cbillid = [result stringForColumn:@"id"];
                NSString *defualtOrder = [result stringForColumn:@"defaultorder"];
                NSString *iparenttype = [result stringForColumn:@"ibookstype"];
                NSDictionary *dic = @{@"kBillIdKey":cbillid,
                                      @"kDefualtOrderKey":defualtOrder,
                                      @"kParentTypeKey":iparenttype};
                [tempArr addObject:dic];
            };
            
            for (NSDictionary *dict in tempArr) {
                NSString *cbillid = [dict objectForKey:@"kBillIdKey"];
                NSString *defualtOrder = [dict objectForKey:@"kDefualtOrderKey"];
                NSString *iparenttype = [dict objectForKey:@"kParentTypeKey"];
                NSArray *parentArr = [iparenttype componentsSeparatedByString:@","];
                for (NSString *parenttype in parentArr) {
                    if ([parenttype integerValue]) {
                        if (![db executeUpdate:@"insert into bk_user_bill select cuserid ,? , 1, ?, ?, 1, ?, cbooksid from bk_books_type where iparenttype = ? and operatortype <> 2 and cuserid = ?",cbillid,writeDate,@(SSJSyncVersion()),defualtOrder,parenttype,userId]) {
                            return [db lastError];
                        }
                    }
                }
            }
        }
    }else{
        // 如果本地有数据
        if (hasUpdated) {
            // 如果后端数据库已经升级过了,则执行正常的合并操作
            [self mergeRecords:records forUserId:userId inDatabase:db error:nil];
        }else{
            // 如果没有升级,则直接抛弃
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
