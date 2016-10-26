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
    
}

@end

#pragma mark - 信用卡

@implementation SSJAccountsMergeCreditTable

@end

#pragma mark - 账本

@implementation SSJAccountsMergeBooksTable

@end

#pragma mark - 借贷款

@implementation SSJAccountsMergeLoanTable

@end

#pragma mark - 周期记账

@implementation SSJAccountsMergePeriodChargeTable

@end

#pragma mark - 流水

@implementation SSJAccountsMergeChargeTable

@end

#pragma mark - 成员流水

@implementation SSJAccountsMergeMemberChargeTable

@end

