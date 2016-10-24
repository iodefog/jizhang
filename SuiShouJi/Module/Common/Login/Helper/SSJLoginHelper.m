//
//  SSJLoginHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/5/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoginHelper.h"
#import "SSJDatabaseQueue.h"

@implementation SSJLoginHelper

+ (void)updateBillTypeOrderIfNeededForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    if (![db executeUpdate:@"update bk_user_bill set iorder = (select defaultorder from bk_bill_type where bk_user_bill.cbillid = bk_bill_type.id), cwritedate = ?, iversion = ?, operatortype = 1 where iorder is null and cuserid = ?", [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), userId]) {
        *error = [db lastError];
    }
}



+ (NSMutableDictionary *)remindIdMapping {
    static NSMutableDictionary *mapping = nil;
    if (!mapping) {
        mapping = [NSMutableDictionary dictionary];
    }
    return mapping;
}

+ (NSMutableDictionary *)memberIdMapping {
    static NSMutableDictionary *mapping = nil;
    if (!mapping) {
        mapping = [NSMutableDictionary dictionary];
    }
    return mapping;
}

+ (NSMutableDictionary *)billIdMapping {
    static NSMutableDictionary *mapping = nil;
    if (!mapping) {
        mapping = [NSMutableDictionary dictionary];
    }
    return mapping;
}

+ (NSMutableDictionary *)fundIdMapping {
    static NSMutableDictionary *mapping = nil;
    if (!mapping) {
        mapping = [NSMutableDictionary dictionary];
    }
    return mapping;
}

+ (NSMutableDictionary *)bookIdMapping {
    static NSMutableDictionary *mapping = nil;
    if (!mapping) {
        mapping = [NSMutableDictionary dictionary];
    }
    return mapping;
}

+ (NSMutableDictionary *)loanIdMapping {
    static NSMutableDictionary *mapping = nil;
    if (!mapping) {
        mapping = [NSMutableDictionary dictionary];
    }
    return mapping;
}

+ (NSMutableDictionary *)periodChargeIdMapping {
    static NSMutableDictionary *mapping = nil;
    if (!mapping) {
        mapping = [NSMutableDictionary dictionary];
    }
    return mapping;
}

+ (NSMutableDictionary *)chargeIdMapping {
    static NSMutableDictionary *mapping = nil;
    if (!mapping) {
        mapping = [NSMutableDictionary dictionary];
    }
    return mapping;
}

+ (NSString *)queryNotLoginUserIdHasCharge {
    NSString *userId = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
//        [db executeQuery:@"select u.cuserid from bk_user as u, bk_user_charge as uc, bk_ where "]
    }];
    return userId;
}

+ (void)mergeUserDataForUserID:(NSString *)userId success:(void (^)())success failure:(void (^)(NSError *error))failure {
    
    NSString *currentUserId = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSError *error = nil;
        NSDictionary *billIdMapping = nil;
        NSDictionary *fundIdMapping = nil;
        NSDictionary *booksIdMapping = nil;
        
        // 合并收支类别
        billIdMapping = [self mergeBillTypeInDatabse:db oldUserId:userId newUserId:currentUserId error:&error];
        if (error) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        // 合并资金账户
        fundIdMapping = [self mergeFundAccountInDatabase:db oldUserId:userId newUserId:currentUserId error:&error];
        if (error) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        // 合并账本
        booksIdMapping = [self mergeBooksTypeInDatabse:db oldUserId:userId newUserId:currentUserId error:&error];
        if (error) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        // 把定期记账转移到登录账户下
        if (![db executeUpdate:@"update bk_charge_period_config set cuserid = ? where cuserid = ?", userId, currentUserId]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 合并记账流水
//        [self mergeUserChargeInDatabse:db oldUserId:userId newUserId:currentUserId billIdMapping:billIdMapping fundIdMapping:fundIdMapping booksIdMapping:booksIdMapping error:&error];
        if (error) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        // 合并成员
        
        // 合并成员流水
        
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

+ (NSDictionary *)mergeUserRemindInDatabase:(FMDatabase *)db oldUserId:(NSString *)oldUserId newUserId:(NSString *)newUserId error:(NSError **)error {
    
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    NSMutableArray *newRemindRecords = [NSMutableArray array];
    
    FMResultSet *resultSet = [db executeQuery:@"select cremindid, cremindname, cmemo, cstartdate, istate, itype, icycle, iisend from bk_user_remind where cuserid = ? and operatortype <> 2 and itype <> 1"];
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
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
        
        [newRemindRecords addObject:@{@"cremindid":newRemindId,
                                      @"cremindname":name,
                                      @"cmemo":memo,
                                      @"cstartdate":startDate,
                                      @"istate":state,
                                      @"itype":type,
                                      @"icycle":cycle,
                                      @"iisend":isEnd,
                                      @"iversion":@(SSJSyncVersion()),
                                      @"operatortype":@(0),
                                      @"cwritedate":writeDate}];
        
        [mapping setObject:newRemindId forKey:remindId];
    }
    [resultSet close];
    
    for (NSDictionary *remindRecord in newRemindRecords) {
        if (![db executeUpdate:@"insert into bk_user_remind (cremindid, cremindname, cmemo, cstartdate, istate, itype, icycle, iisend, iversion, operatortype, cwritedate) values (:cremindid, :cremindname, :cmemo, :cstartdate, :istate, :itype, :icycle, :iisend, :iversion, :operatortype, :cwritedate)" withParameterDictionary:remindRecord]) {
            
            *error = [db lastError];
            return nil;
        }
    }
    
    return mapping;
}

+ (NSDictionary *)mergeMemberInDatabase:(FMDatabase *)db oldUserId:(NSString *)oldUserId newUserId:(NSString *)newUserId error:(NSError **)error {
    
    NSMutableArray *memberIds = [NSMutableArray array];
    
    // 查询有流水的成员
    FMResultSet *resultSet = [db executeQuery:@"select distinct cmemberid from bk_member_charge where operatortype <> 2 and cuserid = ?", oldUserId];
    while ([resultSet next]) {
        NSString *memberId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"cmemberid"]];
        [memberIds addObject:memberId];
    }
    [resultSet close];
    
    // 查询有定期记账的成员
    resultSet = [db executeQuery:@"select distinct cmemberids from bk_charge_period_config where cuserid = ?", oldUserId];
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
        return nil;
    }
    
    NSMutableDictionary *memberIdMapping = [NSMutableDictionary dictionary];
    NSString *allMemberIdStr = [memberIds componentsJoinedByString:@","];
    
    // 查询名称重复的成员id
    NSMutableArray *repeatIds = [NSMutableArray array];
    NSString *sql_1 = [NSString stringWithFormat:@"select a.cmemberid as oldId, b.cmemberid as newId from bk_member as a, bk_member as b where a.cuserid = ? and b.cuserid = ? and a.cname = b.cname and a.cmemberid in (%@) order by b.cwritedate", allMemberIdStr];
    resultSet = [db executeQuery:sql_1, oldUserId, newUserId];
    
    while ([resultSet next]) {
        NSString *newId = [resultSet stringForColumn:@"newId"];
        NSString *oldId = [resultSet stringForColumn:@"oldId"];
        [repeatIds addObject:[NSString stringWithFormat:@"'%@'", oldId]];
        [memberIdMapping setObject:newId forKey:oldId];
    }
    [resultSet close];
    
    int maxOrder = [db intForQuery:@"select max(iorder) from bk_member where cuserid = ?", newUserId];
    
    // 查询名称未重复的成员，copy到登录账户下
    NSMutableArray *newMemberRecords = [NSMutableArray array];
    NSString *repeatMemberIdStr = [repeatIds componentsJoinedByString:@","];
    NSMutableString *sql_2 = [[NSString stringWithFormat:@"select cmemberid, cname, ccolor, istate, cadddate, operatortype from bk_member where cuserid = ? and cmemberid in (%@) and cmemberid not in (%@)", allMemberIdStr, repeatMemberIdStr] mutableCopy];
    resultSet = [db executeQuery:sql_2, oldUserId];
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    while ([resultSet next]) {
        NSString *memberId = [resultSet stringForColumn:@"cmemberid"];
        NSString *name = [resultSet stringForColumn:@"cname"];
        NSString *color = [resultSet stringForColumn:@"ccolor"];
        NSString *state = [resultSet stringForColumn:@"istate"];
        NSString *addDate = [resultSet stringForColumn:@"cadddate"];
        NSString *operatorType = [resultSet stringForColumn:@"operatortype"];
        NSString *newMemberId = SSJUUID();
        
        [newMemberRecords addObject:@{@"cmemberid":newMemberId,
                                      @"cname":name,
                                      @"ccolor":color,
                                      @"istate":state,
                                      @"cadddate":addDate,
                                      @"iorder":@(maxOrder ++),
                                      @"cuserid":newUserId,
                                      @"iversion":@(SSJSyncVersion()),
                                      @"cwritedate":writeDate,
                                      @"operatortype":operatorType}];
        
        [memberIdMapping setObject:newMemberId forKey:memberId];
    }
    [resultSet close];
    
    for (NSDictionary *memberRecord in newMemberRecords) {
        if (![db executeUpdate:@"insert into bk_member (cmemberid, cname, ccolor, istate, cadddate, iorder, cuserid, iversion, cwritedate, operatortype) values (:cmemberid, :cname, :ccolor, :istate, :cadddate, :iorder, :cuserid, :iversion, :cwritedate, :operatortype)" withParameterDictionary:memberRecord]) {
            *error = [db lastError];
            return nil;
        }
    }
    
    return memberIdMapping;
}

+ (NSDictionary *)mergeBillTypeInDatabse:(FMDatabase *)db oldUserId:(NSString *)oldUserId newUserId:(NSString *)newUserId error:(NSError **)error {
    
    NSMutableArray *billIds = [NSMutableArray array];
    
    // 查询有流水的自定义收支类别
    FMResultSet *resultSet = [db executeQuery:@"select distinct uc.ibillid from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and bt.icustom = 1 and uc.operatortype <> 2 and uc.cuserid = ?", oldUserId];
    while ([resultSet next]) {
        NSString *billId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"ibillid"]];
        [billIds addObject:billId];
    }
    [resultSet close];
    
    // 查询有定期记账的自定义收支类别
    resultSet = [db executeQuery:@"select distinct cp.ibillid from bk_charge_period_config as cp, bk_bill_type as bt where bt.icustom = 1 and cp.operatortype <> 2 and cp.cuserid = ?", oldUserId];
    while ([resultSet next]) {
        NSString *billId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"ibillid"]];
        if (![billIds containsObject:billId]) {
            [billIds addObject:billId];
        }
    }
    [resultSet close];
    
    if (billIds.count == 0) {
        return nil;
    }
    
    // 创建个临时表存储类别ID、类别名称、userid，再从临时表中查询名称重复的收支类别id
    if (![db executeUpdate:@"create temporary table if not exists tmpTable (id text, name text, userid text, cwritedate text, primary key(id, userid))"]) {
        *error = [db lastError];
        return nil;
    }
    
    if (![db executeUpdate:@"insert into tmpTable (id, name, userid, cwritedate) select bt.id, bt.cname, ub.cuserid, ub.cwritedate from bk_user_bill as ub, bk_bill_type as bt where ub.cbillid = bt.id and bt.icustom = 1"]) {
        *error = [db lastError];
        return nil;
    }
    
    NSMutableDictionary *billIdMapping = [NSMutableDictionary dictionary];
    NSString *allBillIdStr = [billIds componentsJoinedByString:@","];
    
    // 查询名称重复的类别id
    NSString *sql_1 = [NSString stringWithFormat:@"select a.id as oldBillId, b.id as newBillId from tmpTable as a, tmpTable as b where a.userid = ? and b.userid = ? and a.name = b.name and a.id in (%@) order by b.cwritedate", allBillIdStr];
    resultSet = [db executeQuery:sql_1, oldUserId, newUserId];
    
    NSMutableArray *repeatedBillIds = [NSMutableArray array];
    while ([resultSet next]) {
        NSString *oldBillId = [resultSet stringForColumn:@"oldBillId"];
        NSString *newBillId = [resultSet stringForColumn:@"newBillId"];
        if (oldBillId) {
            [repeatedBillIds addObject:[NSString stringWithFormat:@"'%@'", oldBillId]];
        }
        if (oldBillId && newBillId) {
            [billIdMapping setObject:newBillId forKey:oldBillId];
        }
    }
    [resultSet close];
    [db executeUpdate:@"drop table tmpTable"];
    
    int maxOpenOrder = [db intForQuery:@"select max(iorder) from bk_user_bill where cuserid = ? and istate = 1", newUserId];
    int maxCloseOrder = [db intForQuery:@"select max(iorder) from bk_user_bill where cuserid = ? and istate = 0", newUserId];
    
    // 查询未重复的自定义类别
    NSMutableString *sql_2 = [[NSString stringWithFormat:@"select cbillid, istate, operatortype from bk_user_bill where cuserid = ? and cbillid in (%@)", allBillIdStr] mutableCopy];
    if (repeatedBillIds.count) {
        NSString *repeatBillIdStr = [repeatedBillIds componentsJoinedByString:@","];
        [sql_2 appendFormat:@" and cbillid not in (%@)", repeatBillIdStr];
    }
    resultSet = [db executeQuery:sql_2, oldUserId];
    
    NSMutableArray *newUserBillRecords = [NSMutableArray array];
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    while ([resultSet next]) {
        NSString *billId = [resultSet stringForColumn:@"cbillid"];
        NSString *state = [resultSet stringForColumn:@"istate"];
        NSString *operatorType = [resultSet stringForColumn:@"operatortype"];
        int order = [state isEqualToString:@"1"] ? maxOpenOrder ++ : maxCloseOrder ++;
        
        [newUserBillRecords addObject:@{@"cuserid":newUserId,
                                        @"cbillid":billId,
                                        @"istate":state,
                                        @"iorder":@(order),
                                        @"iversion":@(SSJSyncVersion()),
                                        @"cwitedate":writeDate,
                                        @"operatortype":operatorType}];
        
        [billIdMapping setObject:billId forKey:billId];
    }
    [resultSet close];
    
    for (NSDictionary *billRecord in newUserBillRecords) {
        if (![db executeUpdate:@"insert into bk_user_bill (cuserid, cbillid, istate, iorder, iversion, cwitedate, operatortype) values (:cuserid, :cbillid, :istate, :iorder, :iversion, :cwitedate, :operatortype)" withParameterDictionary:billRecord]) {
            *error = [db lastError];
            return nil;
        }
    }
    
    return billIdMapping;
}

/**
 合并含有有效流水（除平帐收入、平帐支出外）、定期记账的资金账户
 */
+ (NSDictionary *)mergeFundAccountInDatabase:(FMDatabase *)db oldUserId:(NSString *)oldUserId newUserId:(NSString *)newUserId error:(NSError **)error {
    
    NSMutableArray *fundIds = [NSMutableArray array];
    
    // 查询有流水的资金账户，排除平帐收入、支出流水
    FMResultSet *resultSet = [db executeQuery:@"select distinct ifunsid from bk_user_charge where ibillid <> 1 and ibillid <> 2 and operatortype <> 2 and cuserid = ?", oldUserId];
    while ([resultSet next]) {
        NSString *fundId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"ifunsid"]];
        [fundIds addObject:fundId];
    }
    [resultSet close];
    
    // 查询有定期记账的资金账户
    resultSet = [db executeQuery:@"select distinct ifunsid from bk_charge_period_config where operatortype <> 2 and cuserid = ?", oldUserId];
    while ([resultSet next]) {
        NSString *fundId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"ifunsid"]];
        if (![fundIds containsObject:fundId]) {
            [fundIds addObject:fundId];
        }
    }
    [resultSet close];
    
    if (fundIds.count == 0) {
        return nil;
    }
    
    NSString *allFundIdStr = [fundIds componentsJoinedByString:@","];
    
    // 查询名称重复的资金账户id，需要排除信用卡的账户，因为同一账户可以有多个重名的信用卡账户
    NSString *sql_1 = [NSString stringWithFormat:@"select a.cfundid as oldFundId, b.cfundid as newFundId from bk_fund_info as a, bk_fund_info as b where a.cuserid = ? and b.cuserid = ? and a.cacctname = b.cacctname and a.cparent <> '3' and b.cparent <> '3' and a.cfundid in (%@) order by b.cwritedate", allFundIdStr];
    resultSet = [db executeQuery:sql_1, oldUserId, newUserId];
    
    NSMutableArray *repeatedFundIds = [NSMutableArray array];
    NSMutableDictionary *fundIdMapping = [NSMutableDictionary dictionary];
    while ([resultSet next]) {
        NSString *oldFundId = [resultSet stringForColumn:@"oldFundId"];
        NSString *newFundId = [resultSet stringForColumn:@"newFundId"];
        if (oldFundId) {
            [repeatedFundIds addObject:[NSString stringWithFormat:@"'%@'", oldFundId]];
        }
        if (oldFundId && newFundId) {
            [fundIdMapping setObject:newFundId forKey:oldFundId];
        }
    }
    [resultSet close];
    
    int maxOrder = [db intForQuery:@"select max(iorder) from bk_fund_info where cuserid = ?", newUserId];
    
    // 查询没有重复的资金账户，复制到已登录账户下
    NSMutableString *sql_2 = [[NSString stringWithFormat:@"select cfundid, cacctname, cicoin, cparent, ccolor, cmemo, idisplay, operatortype from bk_fund_info where cuserid = ? and cfundid in (%@)", allFundIdStr] mutableCopy];
    if (repeatedFundIds.count) {
        [sql_2 appendFormat:@" and cfundid not in (%@)", [repeatedFundIds componentsJoinedByString:@","]];
    }
    resultSet = [db executeQuery:sql_2, oldUserId];
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSMutableArray *newFundRecords = [NSMutableArray array];
    
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
        
        [newFundRecords addObject:@{@"cfundid":newFundId,
                                    @"cacctname":name,
                                    @"cicoin":icoin,
                                    @"cparent":parent,
                                    @"ccolor":color,
                                    @"cmemo":memo,
                                    @"idisplay":display,
                                    @"iorder":@(maxOrder ++),
                                    @"cuserid":newUserId,
                                    @"operatortype":operatortype,
                                    @"iversion":@(SSJSyncVersion()),
                                    @"cwritedate":writeDate}];
        
        if (oldFundId && newFundId) {
            [fundIdMapping setObject:newFundId forKey:oldFundId];
        }
    }
    [resultSet close];
    
    for (NSDictionary *record in newFundRecords) {
        if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, ccolor, cmemo, idisplay, iorder, cuserid, operatortype, iversion, writeDate) values (:cfundid, :cacctname, :cicoin, :cparent, :ccolor, :cmemo, :idisplay, :iorder, :cuserid, :operatortype, :iversion, :writeDate)" withParameterDictionary:record]) {
            *error = [db lastError];
            return nil;
        }
    }
    
    // 合并信用卡
    NSString *sql_3 = [NSString stringWithFormat:@"select cfundid, iquota, cbilldate, crepaymentdate, cremindid, ibilldatesettlement, operatortype from bk_user_credit where cuserid = ? and cfundid in (%@)", allFundIdStr];
    resultSet = [db executeQuery:sql_3, oldUserId];
    while ([resultSet next]) {
        NSString *cfundid = [resultSet stringForColumn:@"cfundid"];
        NSString *quota = [resultSet stringForColumn:@"iquota"];
        NSString *billDate = [resultSet stringForColumn:@"cbilldate"];
        NSString *repaymentDate = [resultSet stringForColumn:@"crepaymentdate"];
        NSString *remindId = [resultSet stringForColumn:@"cremindid"];
        NSString *billDateSettlement = [resultSet stringForColumn:@"ibilldatesettlement"];
        NSString *operatorType = [resultSet stringForColumn:@"operatortype"];
        NSString *newFundId = fundIdMapping[cfundid];
        
        if (![db executeUpdate:@"insert into bk_user_credit (cfundid, iquota, cbilldate, crepaymentdate, cremindid, ibilldatesettlement, cuserid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", newFundId, quota, billDate, repaymentDate, remindId, billDateSettlement, newUserId, @(SSJSyncVersion()), operatorType, writeDate]) {
            *error = [db lastError];
            [resultSet close];
            return nil;
        }
        
    }
    [resultSet close];
    
    return fundIdMapping;
}

+ (NSDictionary *)mergeBooksTypeInDatabse:(FMDatabase *)db oldUserId:(NSString *)oldUserId newUserId:(NSString *)newUserId error:(NSError **)error {
    
    NSMutableArray *booksIds = [NSMutableArray array];
    
    // 查询有流水的账本，排除特殊流水（平帐、转账、借贷利息），因为这些流水不依赖账本
    FMResultSet *resultSet = [db executeQuery:@"select distinct uc.cbooksid from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and bt.istate <> 2 and uc.operatortype <> 2 and uc.cuserid = ?", oldUserId];
    while ([resultSet next]) {
        NSString *booksId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"cbooksid"]];
        [booksIds addObject:booksId];
    }
    [resultSet close];
    
    // 查询有定期记账的账本
    resultSet = [db executeQuery:@"select distinct cbooksid from bk_charge_period_config where operatortype <> 2 and cuserid = ?", oldUserId];
    while ([resultSet next]) {
        NSString *booksId = [NSString stringWithFormat:@"'%@'", [resultSet stringForColumn:@"cbooksid"]];
        if (![booksIds containsObject:booksId]) {
            [booksIds addObject:booksId];
        }
    }
    [resultSet close];
    
    if (booksIds.count == 0) {
        return nil;
    }
    
    NSMutableDictionary *booksIdMapping = [NSMutableDictionary dictionary];
    NSMutableArray *repeatedBooksIds = [NSMutableArray array];
    NSString *booksIdStr = [booksIds componentsJoinedByString:@","];
    
    // 查询名称重复的账本id
    NSString *sql_1 = [NSString stringWithFormat:@"select a.cbooksid as oldBooksId, b.cbooksid as newBooksId from bk_books_type as a, bk_books_type as b where a.cuserid = ? and b.cuserid = ? and a.cbooksname = b.cbooksname and a.cbooksid in (%@) order by b.cwritedate", booksIdStr];
    resultSet = [db executeQuery:sql_1, oldUserId, newUserId];
    while ([resultSet next]) {
        NSString *oldBooksId = [resultSet stringForColumn:@"oldBooksId"];
        NSString *newBooksId = [resultSet stringForColumn:@"newBooksId"];
        if (oldBooksId) {
            [repeatedBooksIds addObject:[NSString stringWithFormat:@"'%@'", oldBooksId]];
        }
        if (oldBooksId && newBooksId) {
            [booksIdMapping setObject:newBooksId forKey:oldBooksId];
        }
    }
    [resultSet close];
    
    int maxOrder = [db intForQuery:@"select max(iorder) from bk_books_type where cuserid = ?", newUserId];
    
    // 查询没有重复的账本，复制到已登录账户下
    NSMutableString *sql_2 = [[NSString stringWithFormat:@"select cbooksid, cbooksname, cbookscolor, cicoin, operatortype from bk_books_type where cuserid = ? and cbooksid in (%@)", booksIdStr] mutableCopy];
    if (repeatedBooksIds.count) {
        [sql_2 appendFormat:@" and cbooksid not in (%@)", [repeatedBooksIds componentsJoinedByString:@","]];
    }
    resultSet = [db executeQuery:sql_2, oldUserId];
    
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
                                     @"cuserid":newUserId,
                                     @"iversion":@(SSJSyncVersion()),
                                     @"cwritedate":writeDate,
                                     @"operatortype":operatorType}];
        
        [booksIdMapping setObject:newID forKey:ID];
    }
    [resultSet close];
    
    for (NSDictionary *booksRecord in newBooksRecords) {
        if (![db executeUpdate:@"insert into bk_books_type (cbooksid, cbooksname, cbookscolor, cicoin, iorder, cuserid, iversion, cwritedate, operatortype) values (:cbooksid, :cbooksname, :cbookscolor, :cicoin, :iorder, :cuserid, :iversion, :cwritedate, :operatortype)" withParameterDictionary:booksRecord]) {
            *error = [db lastError];
            return nil;
        }
    }
    
    return booksIdMapping;
}

+ (NSDictionary *)mergePeriodChargeInDatabse:(FMDatabase *)db oldUserId:(NSString *)oldUserId newUserId:(NSString *)newUserId error:(NSError **)error {
    
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    NSMutableArray *repeatIds = [NSMutableArray array];
    
    // 通过比较收支类别、金额、周期三个要素判断是否相同，查找出重复的定期记账id
    FMResultSet *resultSet = [db executeQuery:@"select a.iconfigid as oldConfigId, b.iconfigid as newConfigId from bk_charge_period_config as a, bk_charge_period_config as b where a.cuserid = ? and b.cuserid = ? and a.ibillid = b.ibillid and a.imoney = b.imoney and a.itype = b.itype order by b.cwritedate"];
    while ([resultSet next]) {
        NSString *oldConfigId = [resultSet stringForColumn:@"oldConfigId"];
        NSString *newConfigId = [resultSet stringForColumn:@"newConfigId"];
        [mapping setObject:newConfigId forKey:oldConfigId];
        [repeatIds addObject:[NSString stringWithFormat:@"'%@'", oldConfigId]];
    }
    [resultSet close];
    
    // 查找出没有重复的定期记账，并创建一套新的相同记录到登录账户下
    NSMutableString *sql_1 = [[NSString stringWithFormat:@"select iconfigid, ibillid, ifunsid, cbooksid, cmembersid, itype, imoney, cimgurl, cmemo, cbilldate, istate, operatortype from bk_charge_period_config where cuserid = ?"] mutableCopy];
    if (repeatIds.count) {
        [sql_1 appendFormat:@" and iconfigid not in (%@)", [repeatIds componentsJoinedByString:@","]];
    }
    resultSet = [db executeQuery:sql_1, oldUserId];
    
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
        NSString *newBillId = self.billIdMapping[billId];
        NSString *newFundId = self.fundIdMapping[fundId];
        NSString *newBookId = self.bookIdMapping[bookId];
        
        NSMutableArray *newMemberIds = [NSMutableArray array];
        for (NSString *memberId in [memberIds componentsSeparatedByString:@","]) {
            NSString *newMemberId = self.memberIdMapping[memberId];
            if (!newMemberId) {
                SSJPRINT(@"警告：合并顶起记账依赖的成员没有合并到当前账户下");
                continue;
            }
            [newMemberIds addObject:newMemberId];
        }
        
        NSString *newMemberIdStr = [newMemberIds componentsJoinedByString:@","];
        
        if (![db executeUpdate:@"insert into bk_charge_period_config (iconfigid, cuserid, ibillid, ifunsid, cbooksid, cmembersid, itype, imoney, cimgurl, cmemo, cbilldate, istate, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", newConfigId, newUserId, newBillId, newFundId, newBookId, newMemberIdStr, type, money, imgUrl, memo, billDate, state, @(SSJSyncVersion()), writeDate, operatorType]) {
            *error = [db lastError];
            [resultSet close];
            return nil;
        }
        
        [mapping setObject:newConfigId forKey:configId];
    }
    [resultSet close];
    
    return mapping;
}

/**
 合并流水表，合并注意事项：
 1.周期记账生成的流水排重，根据configid和cbilldate判断是否需要排重
 2.借贷生成的流水排重，根据流水的借贷id判断在登录账户的流水中是否存在，已存在说明此流水需要排除
 3.同一次转账的两条流水cwritedate必须相同
 */
+ (NSDictionary *)mergeUserChargeInDatabse:(FMDatabase *)db oldUserId:(NSString *)oldUserId newUserId:(NSString *)newUserId error:(NSError **)error {
    
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    NSMutableArray *repeatIds = [NSMutableArray array];
    
    // 根据周期记账id和记账日期查询两个账户下重复的周期记账生成的流水
    FMResultSet *resultSet = [db executeQuery:@"select a.ichargeid as oldChargeId, b.ichargeid as newChargeId from bk_user_charge as a, bk_user_charge as b where a.iconfigid = b.iconfigid and a.cbilldate = b.cbilldate and a.cuserid = ? and b.cuserid = ? and a.operatortype <> 2", oldUserId, newUserId];
    while ([resultSet next]) {
        NSString *oldChargeId = [resultSet stringForColumn:@"oldChargeId"];
        NSString *newChargeId = [resultSet stringForColumn:@"newChargeId"];
        [repeatIds addObject:[NSString stringWithFormat:@"'%@'", oldChargeId]];
        [mapping setObject:newChargeId forKey:oldChargeId];
    }
    [resultSet close];
    
    // 排重借贷流水
    NSMutableArray *loanChargeInfos = [NSMutableArray array];
    resultSet = [db executeQuery:@"select ichargeid, loanid from bk_user_charge where length(loanid) > 0 and cuserid = ?", oldUserId];
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
        NSString *newLoanId = self.loanIdMapping[loanId];
        if ([db boolForQuery:@"select count(1) from bk_user_charge where cuserid = ? and loanid = ?", newUserId, newLoanId]) {
            [repeatIds addObject:[NSString stringWithFormat:@"'%@'", chargeId]];
        }
    }
    
    // 查询未重复的记账流水，copy到登录账户下
    NSString *repeatIdStr = [repeatIds componentsJoinedByString:@","];
    NSString *sql_1 = [NSString stringWithFormat:@"select ichargeid, cbooksid, loanid, ibillid, ifunsid, iconfigid, imoney, cbilldate, cmemo, cimgurl, thumburl, cwritedate from bk_user_charge where cuserid = ? and operatortype <> 2 and ichargeid not in (%@) and ibillid <> '1' and ibillid <> '2'", repeatIdStr];
    resultSet = [db executeQuery:sql_1, oldUserId];
    
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
        NSString *newBookId = self.bookIdMapping[bookId];
        NSString *newLoanId = self.loanIdMapping[loanId];
        NSString *newBillId = self.billIdMapping[billId] ?: billId;
        NSString *newFundId = self.fundIdMapping[fundId];
        NSString *newConfigId = self.periodChargeIdMapping[configId];
        
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, loanid, ibillid, ifunsid, iconfigid, imoney, cbilldate, cmemo, cimgurl, thumburl, cuserid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", newChargeId, newBookId, newLoanId, newBillId, newFundId, newConfigId, money, billDate, memo, imgUrl, thumbUrl, newUserId, @(SSJSyncVersion()), @0, writeDate]) {
            [resultSet close];
            *error = [db lastError];
            return nil;
        }
        
        [mapping setObject:newChargeId forKey:chargeId];
    }
    [resultSet close];
    
    return mapping;
}

+ (NSDictionary *)mergeLoanInDatabse:(FMDatabase *)db oldUserId:(NSString *)oldUserId newUserId:(NSString *)newUserId error:(NSError **)error {
    
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    NSMutableArray *repeatIds = [NSMutableArray array];
    
    // 查询重复的借贷id，根据借贷日期、接待人判断是否重复
    FMResultSet *resultSet = [db executeQuery:@"select a.loanid as oldLoanId, b.loanid as newLoanId from bk_loan where as a, bk_loan as b where a.cuserid = ? and b.cuserid = ? and a.operatortype <> 2 and a.lender = b.lender and a.cborrowdate = b.cborrowdate", oldUserId, newUserId];
    while ([resultSet next]) {
        NSString *oldLoanId = [resultSet stringForColumn:@"oldLoanId"];
        NSString *newLoanId = [resultSet stringForColumn:@"newLoanId"];
        [mapping setObject:newLoanId forKey:oldLoanId];
        [repeatIds addObject:oldLoanId];
    }
    [resultSet close];
    
    
    
    return mapping;
}

@end
