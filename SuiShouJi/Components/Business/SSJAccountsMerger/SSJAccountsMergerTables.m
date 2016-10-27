//
//  SSJAccountsMergerTables.m
//  SuiShouJi
//
//  Created by old lang on 16/10/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAccountsMergerTables.h"
#import "SSJAccountsMergerMappingManager.h"
#import "FMDB.h"

@interface SSJAccountsMergeVersionManager : NSObject

@end

@implementation SSJAccountsMergeVersionManager

+ (long long)lastMergeVersionWithMajorUserId:(NSString *)majorUserId secondaryUserId:(NSString *)secondaryUserId inDatabase:(FMDatabase *)db {
    int64_t version = 0;
    FMResultSet *resultSet = [db executeQuery:@"select version from bk_acct_merge_version where majoruserid = ? and secondaryuserid = ?", majorUserId, secondaryUserId];
    while ([resultSet next]) {
        version = [resultSet longLongIntForColumn:@"version"];
    }
    [resultSet close];
    
    return version;
}

@end

#pragma mark - 提醒表

@implementation SSJAccountsMergeRemindTable

- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:version];
    NSString *dateStr = [date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 查询重复的提醒，根据提醒名称、类型判断是否重复，排除默认记账提醒
    NSMutableArray *repeatedIds = [NSMutableArray array];
    FMResultSet *resultSet = [db executeQuery:@"select a.cremindid as remindId1, b.cremindid as remindId2 from bk_user_remind as a, bk_user_remind as b where a.cuserid = ? and b.cuserid = ? and a.cremindname = b.cremindname and a.itype = b.itype and a.itype <> 1 and a.operatortype <> 2 and a.cwritedate > ? and order by b.cwritedate", userId1, userId2, dateStr];
    while ([resultSet next]) {
        NSString *remindId1 = [resultSet stringForColumn:@"remindId1"];
        NSString *remindId2 = [resultSet stringForColumn:@"remindId2"];
        [repeatedIds addObject:[NSString stringWithFormat:@"'%@'", remindId1]];
        [[SSJAccountsMergerMappingManager sharedManager].remindIdMapping setObject:remindId2 forKey:remindId1];
    }
    [resultSet close];
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSMutableString *sql = [@"select cremindid, cremindname, cmemo, cstartdate, istate, itype, icycle, iisend from bk_user_remind where cuserid = ? and operatortype <> 2 and itype <> 1 and cwritedate > ?" mutableCopy];
    if (repeatedIds.count > 0) {
        [sql appendFormat:@" and cremindid not in (%@)", [repeatedIds componentsJoinedByString:@","]];
    }
    resultSet = [db executeQuery:sql, userId1, dateStr];
    while ([resultSet next]) {
        NSString *remindId = [resultSet stringForColumn:@"cremindid"];
        NSString *name = [resultSet stringForColumn:@"cremindname"];
        NSString *memo = [resultSet stringForColumn:@"cmemo"];
        NSString *startDate = [resultSet stringForColumn:@"cstartdate"];
        NSString *state = [resultSet stringForColumn:@"istate"];
        NSString *type = [resultSet stringForColumn:@"itype"];
        NSString *cycle = [resultSet stringForColumn:@"icycle"];
        NSString *isEnd = [resultSet stringForColumn:@"iisend"];
        NSString *newRemindId = SSJUUID();
        
        NSDictionary *remindInfo = @{@"cremindid":newRemindId,
                                     @"cremindname":name,
                                     @"cmemo":memo,
                                     @"cstartdate":startDate,
                                     @"istate":state,
                                     @"itype":type,
                                     @"icycle":cycle,
                                     @"iisend":isEnd,
                                     @"cuserid":userId2,
                                     @"iversion":@(SSJSyncVersion()),
                                     @"operatortype":@(0),
                                     @"cwritedate":writeDate};
        
        if (![db executeUpdate:@"insert into bk_user_remind (cremindid, cremindname, cmemo, cstartdate, istate, itype, icycle, iisend, cuserid, iversion, operatortype, cwritedate) values (:cremindid, :cremindname, :cmemo, :cstartdate, :istate, :itype, :icycle, :iisend, :cuserid, :iversion, :operatortype, :cwritedate)" withParameterDictionary:remindInfo]) {
            *error = [db lastError];
            return NO;
        }
        
        [[SSJAccountsMergerMappingManager sharedManager].remindIdMapping setObject:newRemindId forKey:remindId];
    }
    [resultSet close];
    
    return YES;
}

@end

#pragma mark - 成员表

@implementation SSJAccountsMergeMemberTable

- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    NSMutableArray *memberIds = [NSMutableArray array];
    
    // 查询有流水的成员
    FMResultSet *resultSet = [db executeQuery:@"select distinct cmemberid from bk_member_charge where operatortype <> 2 and cuserid = ?", userId1];
    while ([resultSet next]) {
        NSString *memberId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"cmemberid"]];
        [memberIds addObject:memberId];
    }
    [resultSet close];
    
    // 查询有定期记账的成员
    resultSet = [db executeQuery:@"select distinct cmemberids from bk_charge_period_config where operatortype <> 2 and cuserid = ?", userId1];
    while ([resultSet next]) {
        NSString *memberIdsStr = [resultSet stringForColumn:@"ifunsid"];
        NSArray *tMemberIds = [memberIdsStr componentsSeparatedByString:@","];
        for (NSString *memberId in tMemberIds) {
            NSString *tMemberId = [NSString stringWithFormat:@"'%@'", memberId];
            if (![memberIds containsObject:tMemberId]) {
                [memberIds addObject:tMemberId];
            }
        }
    }
    [resultSet close];
    
    if (memberIds.count == 0) {
        return YES;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:version];
    NSString *dateStr = [date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString *allMemberIdStr = [memberIds componentsJoinedByString:@","];
    
    // 查询名称重复的成员id
    NSMutableArray *repeatIds = [NSMutableArray array];
    NSString *sql_1 = [NSString stringWithFormat:@"select a.cmemberid as oldId, b.cmemberid as newId from bk_member as a, bk_member as b where a.cuserid = ? and b.cuserid = ? and a.cname = b.cname and a.cmemberid in (%@) and a.cwritedate > '%@' and order by b.cwritedate", allMemberIdStr, dateStr];
    resultSet = [db executeQuery:sql_1, userId1, userId2];
    
    while ([resultSet next]) {
        NSString *newId = [resultSet stringForColumn:@"newId"];
        NSString *oldId = [resultSet stringForColumn:@"oldId"];
        [repeatIds addObject:[NSString stringWithFormat:@"'%@'", oldId]];
        [[SSJAccountsMergerMappingManager sharedManager].memberIdMapping setObject:newId forKey:oldId];
    }
    [resultSet close];
    
    int maxOrder = [db intForQuery:@"select max(iorder) from bk_member where cuserid = ?", userId2];
    
    // 查询名称未重复的成员，copy到登录账户下
    NSString *repeatMemberIdStr = [repeatIds componentsJoinedByString:@","];
    NSMutableString *sql_2 = [[NSString stringWithFormat:@"select cmemberid, cname, ccolor, istate, cadddate, operatortype from bk_member where cuserid = ? and cmemberid in (%@) and cmemberid not in (%@) and cwritedate > '%@'", allMemberIdStr, repeatMemberIdStr, dateStr] mutableCopy];
    resultSet = [db executeQuery:sql_2, userId1];
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    while ([resultSet next]) {
        NSString *memberId = [resultSet stringForColumn:@"cmemberid"];
        NSString *name = [resultSet stringForColumn:@"cname"];
        NSString *color = [resultSet stringForColumn:@"ccolor"];
        NSString *state = [resultSet stringForColumn:@"istate"];
        NSString *addDate = [resultSet stringForColumn:@"cadddate"];
        NSString *operatorType = [resultSet stringForColumn:@"operatortype"];
        NSString *newMemberId = SSJUUID();
        
        NSDictionary *memeberInfo = @{@"cmemberid":newMemberId,
                                      @"cname":name,
                                      @"ccolor":color,
                                      @"istate":state,
                                      @"cadddate":addDate,
                                      @"iorder":@(maxOrder ++),
                                      @"cuserid":userId2,
                                      @"iversion":@(SSJSyncVersion()),
                                      @"cwritedate":writeDate,
                                      @"operatortype":operatorType};
        
        if (![db executeUpdate:@"insert into bk_member (cmemberid, cname, ccolor, istate, cadddate, iorder, cuserid, iversion, cwritedate, operatortype) values (:cmemberid, :cname, :ccolor, :istate, :cadddate, :iorder, :cuserid, :iversion, :cwritedate, :operatortype)" withParameterDictionary:memeberInfo]) {
            *error = [db lastError];
            return NO;
        }
        
        [[SSJAccountsMergerMappingManager sharedManager].memberIdMapping setObject:newMemberId forKey:memberId];
    }
    [resultSet close];
    
    return YES;
}

@end

#pragma mark - 收支类型

@implementation SSJAccountsMergeBIllTypeTable

- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    NSMutableArray *billIds = [NSMutableArray array];
    
    // 查询有流水的自定义收支类别
    FMResultSet *resultSet = [db executeQuery:@"select distinct uc.ibillid from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and bt.icustom = 1 and uc.operatortype <> 2 and uc.cuserid = ?", userId1];
    while ([resultSet next]) {
        NSString *billId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"ibillid"]];
        [billIds addObject:billId];
    }
    [resultSet close];
    
    // 查询有定期记账的自定义收支类别
    resultSet = [db executeQuery:@"select distinct cp.ibillid from bk_charge_period_config as cp, bk_bill_type as bt where bt.icustom = 1 and cp.operatortype <> 2 and cp.cuserid = ?", userId1];
    while ([resultSet next]) {
        NSString *billId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"ibillid"]];
        if (![billIds containsObject:billId]) {
            [billIds addObject:billId];
        }
    }
    [resultSet close];
    
    if (billIds.count == 0) {
        return YES;
    }
    
    // 创建个临时表存储类别ID、类别名称、userid，再从临时表中查询名称重复的收支类别id
    if (![db executeUpdate:@"create temporary table if not exists tmpTable (id text, name text, userid text, cwritedate text, primary key(id, userid))"]) {
        *error = [db lastError];
        return NO;
    }
    
    if (![db executeUpdate:@"insert into tmpTable (id, name, userid, cwritedate) select bt.id, bt.cname, ub.cuserid, ub.cwritedate from bk_user_bill as ub, bk_bill_type as bt where ub.cbillid = bt.id and bt.icustom = 1"]) {
        *error = [db lastError];
        return NO;
    }
    
    NSString *allBillIdStr = [billIds componentsJoinedByString:@","];
    
    // 查询名称重复的类别id
    NSString *sql_1 = [NSString stringWithFormat:@"select a.id as oldBillId, b.id as newBillId from tmpTable as a, tmpTable as b where a.userid = ? and b.userid = ? and a.name = b.name and a.id in (%@) order by b.cwritedate", allBillIdStr];
    resultSet = [db executeQuery:sql_1, userId1, userId2];
    
    NSMutableArray *repeatedBillIds = [NSMutableArray array];
    while ([resultSet next]) {
        NSString *oldBillId = [resultSet stringForColumn:@"oldBillId"];
        NSString *newBillId = [resultSet stringForColumn:@"newBillId"];
        [repeatedBillIds addObject:[NSString stringWithFormat:@"'%@'", oldBillId]];
        [[SSJAccountsMergerMappingManager sharedManager].billIdMapping setObject:newBillId forKey:oldBillId];
    }
    [resultSet close];
    [db executeUpdate:@"drop table tmpTable"];
    
    int maxOpenOrder = [db intForQuery:@"select max(iorder) from bk_user_bill where cuserid = ? and istate = 1", userId2];
    int maxCloseOrder = [db intForQuery:@"select max(iorder) from bk_user_bill where cuserid = ? and istate = 0", userId2];
    
    // 查询未重复的自定义类别
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSMutableString *sql_2 = [[NSString stringWithFormat:@"select cbillid, istate, operatortype from bk_user_bill where cuserid = ? and cbillid in (%@)", allBillIdStr] mutableCopy];
    if (repeatedBillIds.count) {
        NSString *repeatBillIdStr = [repeatedBillIds componentsJoinedByString:@","];
        [sql_2 appendFormat:@" and cbillid not in (%@)", repeatBillIdStr];
    }
    resultSet = [db executeQuery:sql_2, userId1];
    
    while ([resultSet next]) {
        NSString *billId = [resultSet stringForColumn:@"cbillid"];
        NSString *state = [resultSet stringForColumn:@"istate"];
        NSString *operatorType = [resultSet stringForColumn:@"operatortype"];
        int order = [state isEqualToString:@"1"] ? maxOpenOrder ++ : maxCloseOrder ++;
        
        NSDictionary *billInfo = @{@"cuserid":userId2,
                                   @"cbillid":billId,
                                   @"istate":state,
                                   @"iorder":@(order),
                                   @"iversion":@(SSJSyncVersion()),
                                   @"cwitedate":writeDate,
                                   @"operatortype":operatorType};
        
        if (![db executeUpdate:@"insert into bk_user_bill (cuserid, cbillid, istate, iorder, iversion, cwitedate, operatortype) values (:cuserid, :cbillid, :istate, :iorder, :iversion, :cwitedate, :operatortype)" withParameterDictionary:billInfo]) {
            *error = [db lastError];
            return NO;
        }
        
        [[SSJAccountsMergerMappingManager sharedManager].billIdMapping setObject:billId forKey:billId];
    }
    [resultSet close];
    
    return YES;
}

@end

#pragma mark - 资金账户

@implementation SSJAccountsMergeFundInfoTable

- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    NSMutableArray *fundIds = [NSMutableArray array];
    
    // 查询有流水的资金账户，排除平帐收入、支出流水
    FMResultSet *resultSet = [db executeQuery:@"select distinct ifunsid from bk_user_charge where ibillid <> 1 and ibillid <> 2 and operatortype <> 2 and cuserid = ?", userId1];
    while ([resultSet next]) {
        NSString *fundId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"ifunsid"]];
        [fundIds addObject:fundId];
    }
    [resultSet close];
    
    // 查询有定期记账的资金账户
    resultSet = [db executeQuery:@"select distinct ifunsid from bk_charge_period_config where operatortype <> 2 and cuserid = ?", userId1];
    while ([resultSet next]) {
        NSString *fundId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"ifunsid"]];
        if (![fundIds containsObject:fundId]) {
            [fundIds addObject:fundId];
        }
    }
    [resultSet close];
    
    if (fundIds.count == 0) {
        return YES;
    }
    
    NSString *allFundIdStr = [fundIds componentsJoinedByString:@","];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:version];
    NSString *dateStr = [date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 查询名称重复的资金账户id
    NSString *sql_1 = [NSString stringWithFormat:@"select a.cfundid as oldFundId, b.cfundid as newFundId from bk_fund_info as a, bk_fund_info as b where a.cuserid = ? and b.cuserid = ? and a.cacctname = b.cacctname and a.cfundid in (%@) and a.cwritedate > ? order by b.cwritedate", allFundIdStr];
    resultSet = [db executeQuery:sql_1, userId1, userId2, dateStr];
    
    NSMutableArray *repeatedFundIds = [NSMutableArray array];
    
    while ([resultSet next]) {
        NSString *oldFundId = [resultSet stringForColumn:@"oldFundId"];
        NSString *newFundId = [resultSet stringForColumn:@"newFundId"];
        [repeatedFundIds addObject:[NSString stringWithFormat:@"'%@'", oldFundId]];
        [[SSJAccountsMergerMappingManager sharedManager].fundIdMapping setObject:newFundId forKey:oldFundId];
    }
    [resultSet close];
    
    int maxOrder = [db intForQuery:@"select max(iorder) from bk_fund_info where cuserid = ?", userId2];
    
    // 查询没有重复的资金账户，复制到已登录账户下
    NSMutableString *sql_2 = [[NSString stringWithFormat:@"select cfundid, cacctname, cicoin, cparent, ccolor, cmemo, idisplay, operatortype from bk_fund_info where cuserid = ? and cfundid in (%@) and cwritedate > '%@'", allFundIdStr, dateStr] mutableCopy];
    if (repeatedFundIds.count) {
        [sql_2 appendFormat:@" and cfundid not in (%@)", [repeatedFundIds componentsJoinedByString:@","]];
    }
    resultSet = [db executeQuery:sql_2, userId1];
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    while ([resultSet next]) {
        NSString *name = [resultSet stringForColumn:@"cacctname"];
        NSString *icoin = [resultSet stringForColumn:@"cicoin"];
        NSString *parent = [resultSet stringForColumn:@"cparent"];
        NSString *color = [resultSet stringForColumn:@"ccolor"];
        NSString *memo = [resultSet stringForColumn:@"cmemo"];
        NSString *display = [resultSet stringForColumn:@"idisplay"];
        NSString *operatortype = [resultSet stringForColumn:@"operatortype"];
        NSString *oldFundId = [resultSet stringForColumn:@"cfundid"];
        NSString *newFundId = SSJUUID();
        
        NSDictionary *newFundInfo = @{@"cfundid":newFundId,
                                      @"cacctname":name,
                                      @"cicoin":icoin,
                                      @"cparent":parent,
                                      @"ccolor":color,
                                      @"cmemo":memo,
                                      @"idisplay":display,
                                      @"iorder":@(maxOrder ++),
                                      @"cuserid":userId2,
                                      @"operatortype":operatortype,
                                      @"iversion":@(SSJSyncVersion()),
                                      @"cwritedate":writeDate};
        
        if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, ccolor, cmemo, idisplay, iorder, cuserid, operatortype, iversion, writeDate) values (:cfundid, :cacctname, :cicoin, :cparent, :ccolor, :cmemo, :idisplay, :iorder, :cuserid, :operatortype, :iversion, :writeDate)" withParameterDictionary:newFundInfo]) {
            *error = [db lastError];
            return NO;
        }
        
        [[SSJAccountsMergerMappingManager sharedManager].fundIdMapping setObject:newFundId forKey:oldFundId];
    }
    [resultSet close];
    
    return YES;
}

@end

#pragma mark - 信用卡

@implementation SSJAccountsMergeCreditTable

- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    NSDictionary *fundMapping = [SSJAccountsMergerMappingManager sharedManager].fundIdMapping;
    NSMutableArray *newCreatedFundIDs = [NSMutableArray array];
    for (SSJAccountsMergerMappingModel *model in fundMapping) {
        if (model.newCreated) {
            [newCreatedFundIDs addObject:[NSString stringWithFormat:@"'%@'", model.ID]];
        }
    }
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString *sql_3 = [NSString stringWithFormat:@"select cfundid, iquota, cbilldate, crepaymentdate, cremindid, ibilldatesettlement, operatortype from bk_user_credit where cuserid = ? and cfundid in (%@)", newCreatedFundIDs];
    FMResultSet *resultSet = [db executeQuery:sql_3, userId1];
    
    resultSet = [db executeQuery:@"select cfundid from bk_user_credit where cuserid = ? and cwritedate > ?", ]
    
    while ([resultSet next]) {
        NSString *cfundid = [resultSet stringForColumn:@"cfundid"];
        NSString *quota = [resultSet stringForColumn:@"iquota"];
        NSString *billDate = [resultSet stringForColumn:@"cbilldate"];
        NSString *repaymentDate = [resultSet stringForColumn:@"crepaymentdate"];
        NSString *remindId = [resultSet stringForColumn:@"cremindid"];
        NSString *billDateSettlement = [resultSet stringForColumn:@"ibilldatesettlement"];
        NSString *operatorType = [resultSet stringForColumn:@"operatortype"];
        
        SSJAccountsMergerMappingModel *model = fundMapping[cfundid];
        NSString *newFundId = model.ID;
        
        if (![db executeUpdate:@"insert into bk_user_credit (cfundid, iquota, cbilldate, crepaymentdate, cremindid, ibilldatesettlement, cuserid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", newFundId, quota, billDate, repaymentDate, remindId, billDateSettlement, userId2, @(SSJSyncVersion()), operatorType, writeDate]) {
            *error = [db lastError];
            [resultSet close];
            return NO;
        }
        
    }
    [resultSet close];
    
    return YES;
}

@end

#pragma mark - 账本

@implementation SSJAccountsMergeBooksTable

- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSMutableArray *booksIds = [NSMutableArray array];
    
    // 查询有流水的账本，排除特殊流水（平帐、转账、借贷变更、借贷利息），因为这些流水不依赖账本
    FMResultSet *resultSet = [db executeQuery:@"select distinct uc.cbooksid from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and bt.istate <> 2 and length(uc.cbooksid) > 0 and uc.operatortype <> 2 and uc.cuserid = ?", userId1];
    while ([resultSet next]) {
        NSString *booksId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"cbooksid"]];
        [booksIds addObject:booksId];
    }
    [resultSet close];
    
    // 查询有定期记账的账本
    resultSet = [db executeQuery:@"select distinct cbooksid from bk_charge_period_config where length(cbooksid) > 0 and operatortype <> 2 and cuserid = ?", userId1];
    while ([resultSet next]) {
        NSString *booksId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"cbooksid"]];
        if (![booksIds containsObject:booksId]) {
            [booksIds addObject:booksId];
        }
    }
    [resultSet close];
    
    if (booksIds.count == 0) {
        return YES;
    }
    
    // 查询名称重复的账本id
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:version];
    NSString *dateStr = [date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSMutableArray *repeatedBooksIds = [NSMutableArray array];
    NSString *booksIdStr = [booksIds componentsJoinedByString:@","];
    
    NSString *sql_1 = [NSString stringWithFormat:@"select a.cbooksid as oldBooksId, b.cbooksid as newBooksId from bk_books_type as a, bk_books_type as b where a.cuserid = ? and b.cuserid = ? and a.cbooksname = b.cbooksname and a.cbooksid in (%@) and a.cwritedate > ? order by b.cwritedate", booksIdStr];
    resultSet = [db executeQuery:sql_1, userId1, userId2, dateStr];
    while ([resultSet next]) {
        NSString *oldBooksId = [resultSet stringForColumn:@"oldBooksId"];
        NSString *newBooksId = [resultSet stringForColumn:@"newBooksId"];
        [repeatedBooksIds addObject:[NSString stringWithFormat:@"'%@'", oldBooksId]];
        [[SSJAccountsMergerMappingManager sharedManager].bookIdMapping setObject:newBooksId forKey:oldBooksId];
    }
    [resultSet close];
    
    int maxOrder = [db intForQuery:@"select max(iorder) from bk_books_type where cuserid = ?", userId2];
    
    // 查询没有重复的账本，复制到已登录账户下
    NSMutableString *sql_2 = [[NSString stringWithFormat:@"select cbooksid, cbooksname, cbookscolor, cicoin, operatortype from bk_books_type where cuserid = ? and cbooksid in (%@) and cwritedate > ?", booksIdStr] mutableCopy];
    if (repeatedBooksIds.count) {
        [sql_2 appendFormat:@" and cbooksid not in (%@)", [repeatedBooksIds componentsJoinedByString:@","]];
    }
    resultSet = [db executeQuery:sql_2, userId1, dateStr];
    
    NSMutableArray *newBooksRecords = [NSMutableArray array];
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    while ([resultSet next]) {
        NSString *ID = [resultSet stringForColumn:@"cbooksid"];
        NSString *name = [resultSet stringForColumn:@"cbooksname"];
        NSString *color = [resultSet stringForColumn:@"cbookscolor"];
        NSString *icoin = [resultSet stringForColumn:@"cicoin"];
        NSString *operatorType = [resultSet stringForColumn:@"operatortype"];
        NSString *newID = SSJUUID();
        
        [newBooksRecords addObject:@{@"cbooksid":newID,
                                     @"cbooksname":name,
                                     @"cbookscolor":color,
                                     @"cicoin":icoin,
                                     @"iorder":@(maxOrder ++),
                                     @"cuserid":userId2,
                                     @"iversion":@(SSJSyncVersion()),
                                     @"cwritedate":writeDate,
                                     @"operatortype":operatorType}];
        
        [[SSJAccountsMergerMappingManager sharedManager].bookIdMapping setObject:newID forKey:ID];
    }
    [resultSet close];
    
    for (NSDictionary *booksRecord in newBooksRecords) {
        if (![db executeUpdate:@"insert into bk_books_type (cbooksid, cbooksname, cbookscolor, cicoin, iorder, cuserid, iversion, cwritedate, operatortype) values (:cbooksid, :cbooksname, :cbookscolor, :cicoin, :iorder, :cuserid, :iversion, :cwritedate, :operatortype)" withParameterDictionary:booksRecord]) {
            *error = [db lastError];
            return NO;
        }
    }
    
    return YES;
}

@end

#pragma mark - 借贷款

@implementation SSJAccountsMergeLoanTable

- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    // 查询重复的借贷id，根据借贷日期、借贷人判断是否重复
    NSMutableArray *repeatIds = [NSMutableArray array];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:version];
    NSString *dateStr = [date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSMutableDictionary *mapping = [SSJAccountsMergerMappingManager sharedManager].loanIdMapping;
    
    FMResultSet *resultSet = [db executeQuery:@"select a.loanid as oldLoanId, b.loanid as newLoanId from bk_loan where as a, bk_loan as b where a.cuserid = ? and b.cuserid = ? and a.operatortype <> 2 and a.lender = b.lender and a.cborrowdate = b.cborrowdate and a.cwritedate > ? order by b.cwritedate", userId1, userId2, dateStr];
    while ([resultSet next]) {
        NSString *oldLoanId = [resultSet stringForColumn:@"oldLoanId"];
        NSString *newLoanId = [resultSet stringForColumn:@"newLoanId"];
        [mapping setObject:newLoanId forKey:oldLoanId];
        [repeatIds addObject:[NSString stringWithFormat:@"'%@'", oldLoanId]];
    }
    [resultSet close];
    
    // 查找出没有重复的借贷，并创建一套新的相同记录到登录账户下
    NSMutableString *sql_1 = [[NSString stringWithFormat:@"select loanid, lender, jmoney, cthefundid, ctargetfundid, cetarget, cborrowdate, crepaymentdate, cenddate, rate, memo, interest, cremindid, itype, iend from bk_loan where cuserid = ? and operatortype <> 2 and cwritedate > ?"] mutableCopy];
    if (repeatIds.count) {
        [sql_1 appendFormat:@" and loanid not in (%@)", [repeatIds componentsJoinedByString:@","]];
    }
    resultSet = [db executeQuery:sql_1, userId1, dateStr];
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    while ([resultSet next]) {
        NSString *loanId = [resultSet stringForColumn:@"loanid"];
        NSString *lender = [resultSet stringForColumn:@"lender"];
        NSString *money = [resultSet stringForColumn:@"jmoney"];
        NSString *fundId = [resultSet stringForColumn:@"cthefundid"];
        NSString *targetFundId = [resultSet stringForColumn:@"ctargetfundid"];
        NSString *endTargetFundId = [resultSet stringForColumn:@"cetarget"];
        NSString *borrowDate = [resultSet stringForColumn:@"cborrowdate"];
        NSString *repaymentDate = [resultSet stringForColumn:@"crepaymentdate"];
        NSString *endDate = [resultSet stringForColumn:@"cenddate"];
        NSString *rate = [resultSet stringForColumn:@"rate"];
        NSString *memo = [resultSet stringForColumn:@"memo"];
        NSString *interest = [resultSet stringForColumn:@"interest"];
        NSString *remindId = [resultSet stringForColumn:@"cremindid"];
        NSString *type = [resultSet stringForColumn:@"itype"];
        NSString *end = [resultSet stringForColumn:@"iend"];
        
        NSString *newLoanId = SSJUUID();
        
        NSDictionary *fundMapping = [SSJAccountsMergerMappingManager sharedManager].fundIdMapping;
        NSString *newFundId = ((SSJAccountsMergerMappingModel *)fundMapping[fundId]).ID;
        NSString *newTargetFundId = ((SSJAccountsMergerMappingModel *)fundMapping[targetFundId]).ID;
        NSString *newEndTargetFundId = ((SSJAccountsMergerMappingModel *)fundMapping[endTargetFundId]).ID;
        NSString *newRemindId = [[SSJAccountsMergerMappingManager sharedManager].remindIdMapping objectForKey:remindId];
        
        if (![db executeUpdate:@"insert info bk_loan (loanid, lender, jmoney, cthefundid, ctargetfundid, cetarget, cborrowdate, crepaymentdate, cenddate, rate, memo, interest, cremindid, itype, iend, cuserid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", newLoanId, lender, money, newFundId, newTargetFundId, newEndTargetFundId, borrowDate, repaymentDate, endDate, rate, memo, interest, newRemindId, type, end, userId2, @(SSJSyncVersion()), @0, writeDate]) {
            [resultSet close];
            return NO;
        }
        
        [mapping setObject:newLoanId forKey:loanId];
    }
    [resultSet close];
    
    return YES;
}

@end

#pragma mark - 周期记账

@implementation SSJAccountsMergePeriodChargeTable

- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    NSMutableArray *repeatIds = [NSMutableArray array];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:version];
    NSString *dateStr = [date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSMutableDictionary *mapping = [SSJAccountsMergerMappingManager sharedManager].periodChargeIdMapping;
    
    // 通过比较收支类别、金额、周期三个要素判断是否相同，查找出重复的定期记账id
    FMResultSet *resultSet = [db executeQuery:@"select a.iconfigid as oldConfigId, b.iconfigid as newConfigId from bk_charge_period_config as a, bk_charge_period_config as b where a.cuserid = ? and b.cuserid = ? and a.ibillid = b.ibillid and a.imoney = b.imoney and a.itype = b.itype and a.cwritedate > ? order by b.cwritedate", userId1, userId2, dateStr];
    while ([resultSet next]) {
        NSString *oldConfigId = [resultSet stringForColumn:@"oldConfigId"];
        NSString *newConfigId = [resultSet stringForColumn:@"newConfigId"];
        [mapping setObject:newConfigId forKey:oldConfigId];
        [repeatIds addObject:[NSString stringWithFormat:@"'%@'", oldConfigId]];
    }
    [resultSet close];
    
    // 查找出没有重复的定期记账，并创建一套新的相同记录到登录账户下
    NSMutableString *sql_1 = [[NSString stringWithFormat:@"select iconfigid, ibillid, ifunsid, cbooksid, cmembersid, itype, imoney, cimgurl, cmemo, cbilldate, istate, operatortype from bk_charge_period_config where cuserid = ? and cwritedate > ?"] mutableCopy];
    if (repeatIds.count) {
        [sql_1 appendFormat:@" and iconfigid not in (%@)", [repeatIds componentsJoinedByString:@","]];
    }
    resultSet = [db executeQuery:sql_1, userId1, dateStr];
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    while ([resultSet next]) {
        NSString *configId = [resultSet stringForColumn:@"iconfigid"];
        NSString *billId = [resultSet stringForColumn:@"ibillid"];
        NSString *fundId = [resultSet stringForColumn:@"ifunsid"];
        NSString *bookId = [resultSet stringForColumn:@"cbooksid"];
        NSString *memberIds = [resultSet stringForColumn:@"cmembersid"];
        NSString *type = [resultSet stringForColumn:@"itype"];
        NSString *money = [resultSet stringForColumn:@"imoney"];
        NSString *imgUrl = [resultSet stringForColumn:@"cimgurl"];
        NSString *memo = [resultSet stringForColumn:@"cmemo"];
        NSString *billDate = [resultSet stringForColumn:@"cbilldate"];
        NSString *state = [resultSet stringForColumn:@"istate"];
        NSString *operatorType = [resultSet stringForColumn:@"operatortype"];
        
        NSString *newConfigId = SSJUUID();
        NSString *newBillId = [[SSJAccountsMergerMappingManager sharedManager].billIdMapping objectForKey:billId];
        NSString *newBookId = [[SSJAccountsMergerMappingManager sharedManager].bookIdMapping objectForKey:bookId];
        SSJAccountsMergerMappingModel *model = [[SSJAccountsMergerMappingManager sharedManager].fundIdMapping objectForKey:fundId];
        NSString *newFundId = model.ID;
        
        NSMutableArray *newMemberIds = [NSMutableArray array];
        for (NSString *memberId in [memberIds componentsSeparatedByString:@","]) {
            NSString *newMemberId = [[SSJAccountsMergerMappingManager sharedManager].memberIdMapping objectForKey:memberId];
            if (!newMemberId) {
                SSJPRINT(@"警告：合并顶起记账依赖的成员没有合并到当前账户下");
                continue;
            }
            [newMemberIds addObject:newMemberId];
        }
        
        NSString *newMemberIdStr = [newMemberIds componentsJoinedByString:@","];
        
        if (![db executeUpdate:@"insert into bk_charge_period_config (iconfigid, cuserid, ibillid, ifunsid, cbooksid, cmembersid, itype, imoney, cimgurl, cmemo, cbilldate, istate, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", newConfigId, userId2, newBillId, newFundId, newBookId, newMemberIdStr, type, money, imgUrl, memo, billDate, state, @(SSJSyncVersion()), writeDate, operatorType]) {
            *error = [db lastError];
            [resultSet close];
            return NO;
        }
        
        [mapping setObject:newConfigId forKey:configId];
    }
    [resultSet close];
    
    return YES;
}

@end

#pragma mark - 流水

@implementation SSJAccountsMergeChargeTable

/**
 合并流水表，合并注意事项：
 1.排重周期记账生成的流水，根据configid和cbilldate判断是否需要排重
 2.排重借贷生成的流水，根据流水的借贷id判断在登录账户的流水中是否存在，已存在说明此流水需要排除
 3.同一次转账的两条流水cwritedate必须相同
 */
- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    NSMutableDictionary *mapping = [SSJAccountsMergerMappingManager sharedManager].chargeIdMapping;
    NSMutableArray *repeatIds = [NSMutableArray array];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:version];
    NSString *dateStr = [date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 根据周期记账id和记账日期查询两个账户下重复的周期记账生成的流水
    NSMutableArray *chargeInfos = [NSMutableArray array];
    FMResultSet *resultSet = [db executeQuery:@"select ichargeid, iconfigid, cbilldate from bk_user_charge where cuserid = ? and cwritedate > ? and length(iconfigid) > 0", userId1, dateStr];
    while ([resultSet next]) {
        NSString *chargeId = [resultSet stringForColumn:@"ichargeid"];
        NSString *billDate = [resultSet stringForColumn:@"cbilldate"];
        NSString *configId = [resultSet stringForColumn:@"iconfigid"];
        NSString *mappedConfigId = [[SSJAccountsMergerMappingManager sharedManager].periodChargeIdMapping objectForKey:configId];
        [chargeInfos addObject:@{@"chargeId":chargeId,
                                 @"configId":mappedConfigId,
                                 @"billDate":billDate}];
    }
    [resultSet close];
    
    for (NSDictionary *chargeInfo in chargeInfos) {
        NSString *chargeId = chargeInfo[@"chargeId"];
        NSString *configId = chargeInfo[@"configId"];
        NSString *billDate = chargeInfo[@"billDate"];
        if ([db boolForQuery:@"select count(1) from bk_user_charge where iconfigid = ? and cbilldate = ? and cuserid = ?", configId, billDate, userId2]) {
            [repeatIds addObject:[NSString stringWithFormat:@"'%@'", chargeId]];
        }
    }
    
    // 排重借贷流水
    NSMutableArray *loanChargeInfos = [NSMutableArray array];
    resultSet = [db executeQuery:@"select ichargeid, loanid from bk_user_charge where length(loanid) > 0 and cuserid = ? and cwritedate > ?", userId1, dateStr];
    while ([resultSet next]) {
        NSString *chargeId = [resultSet stringForColumn:@"ichargeid"];
        NSString *loanId = [resultSet stringForColumn:@"loanid"];
        [loanChargeInfos addObject:@{@"ichargeid":chargeId,
                                     @"loanid":loanId}];
    }
    [resultSet close];
    
    for (NSDictionary *loanChargeInfo in loanChargeInfos) {
        NSString *chargeId = loanChargeInfo[@"ichargeid"];
        NSString *loanId = loanChargeInfo[@"loanid"];
        NSString *mappedLoanId = [[SSJAccountsMergerMappingManager sharedManager].loanIdMapping objectForKey:loanId];
        if ([db boolForQuery:@"select count(1) from bk_user_charge where cuserid = ? and loanid = ?", userId2, mappedLoanId]) {
            [repeatIds addObject:[NSString stringWithFormat:@"'%@'", chargeId]];
        }
    }
    
    // 查询未重复的记账流水，copy到登录账户下
    NSString *repeatIdStr = [repeatIds componentsJoinedByString:@","];
    NSString *sql_1 = [NSString stringWithFormat:@"select ichargeid, cbooksid, loanid, ibillid, ifunsid, iconfigid, imoney, cbilldate, cmemo, cimgurl, thumburl, cwritedate from bk_user_charge where cuserid = ? and operatortype <> 2 and ichargeid not in (%@) and ibillid <> '1' and ibillid <> '2' and cwritedate > ?", repeatIdStr];
    resultSet = [db executeQuery:sql_1, userId1, dateStr];
    
    NSString *commonWriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    while ([resultSet next]) {
        NSString *chargeId = [resultSet stringForColumn:@"ichargeid"];
        NSString *bookId = [resultSet stringForColumn:@"cbooksid"];
        NSString *loanId = [resultSet stringForColumn:@"loanid"];
        NSString *billId = [resultSet stringForColumn:@"ibillid"];
        NSString *fundId = [resultSet stringForColumn:@"ifunsid"];
        NSString *configId = [resultSet stringForColumn:@"iconfigid"];
        
        NSString *money = [resultSet stringForColumn:@"imoney"];
        NSString *billDate = [resultSet stringForColumn:@"cbilldate"];
        NSString *memo = [resultSet stringForColumn:@"cmemo"];
        NSString *imgUrl = [resultSet stringForColumn:@"cimgurl"];
        NSString *thumbUrl = [resultSet stringForColumn:@"thumburl"];
        
        NSString *writeDate = nil;
        if ([billId isEqualToString:@"3"] || [billId isEqualToString:@"4"]) {
            NSString *dateStr = [resultSet stringForColumn:@"cwritedate"];
            NSDate *tmpDate = [NSDate dateWithString:dateStr formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
            tmpDate = [tmpDate dateByAddingSeconds:1];
            writeDate = [tmpDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        } else {
            writeDate = commonWriteDate;
        }
        
        NSString *newChargeId = SSJUUID();
        NSString *newBookId = [[SSJAccountsMergerMappingManager sharedManager].bookIdMapping objectForKey:bookId];
        NSString *newLoanId = [[SSJAccountsMergerMappingManager sharedManager].loanIdMapping objectForKey:loanId];
        // billIdMapping里只保存user_bill里的id，istate为2的特殊类别不在user_bill里
        NSString *newBillId = [[SSJAccountsMergerMappingManager sharedManager].billIdMapping objectForKey:billId] ?: billId;
        NSString *newConfigId = [[SSJAccountsMergerMappingManager sharedManager].periodChargeIdMapping objectForKey:configId];
        NSString *newFundId = self.fundIdMapping[fundId];
        
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, loanid, ibillid, ifunsid, iconfigid, imoney, cbilldate, cmemo, cimgurl, thumburl, cuserid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", newChargeId, newBookId, newLoanId, newBillId, newFundId, newConfigId, money, billDate, memo, imgUrl, thumbUrl, userId2, @(SSJSyncVersion()), @0, writeDate]) {
            [resultSet close];
            *error = [db lastError];
            return NO;
        }
        
        [mapping setObject:newChargeId forKey:chargeId];
    }
    [resultSet close];
    
    return YES;
}

@end

#pragma mark - 成员流水

@implementation SSJAccountsMergeMemberChargeTable

@end

