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
        
        // 查询名称重复的资金账户id
        FMResultSet *resultSet = [db executeQuery:@"select a.cfundid as oldFundId, b.cfundid as newFundId from bk_fund_info as a, bk_fund_info as b where a.cuserid = ? and b.cuserid = ? and a.cacctname = b.cacctname", userId, currentUserId];
        
        NSMutableArray *repeatedFundIds = [NSMutableArray array];
        while ([resultSet next]) {
            NSString *oldFundId = [resultSet stringForColumn:@"oldFundId"];
            if (oldFundId) {
                [repeatedFundIds addObject:[NSString stringWithFormat:@"'%@'", oldFundId]];
            }
        }
        [resultSet close];
        
        // 把名称未重复的资金账户移到登录账户下
        NSMutableString *sql = [@"update bk_fund_info set cuserid = ?, iversion = ?, cwritedate = ?, operatortype = 1 where cuserid = ?" mutableCopy];
        if (repeatedFundIds.count) {
            [sql appendFormat:@" and cfundid not in (%@)", [repeatedFundIds componentsJoinedByString:@","]];
        }
        
        if (![db executeUpdate:sql, currentUserId, @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], userId]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 查询名称重复的收支类别id
        if (![db executeUpdate:@"create temporary table tmpTable (id text, name text, userid text, primary key(id, userid))"]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (![db executeUpdate:@"insert into tmpTable (id, name, userid) select bt.id, bt.cname, ub.cuserid from bk_user_bill as ub, bk_bill_type as bt where ub.cbillid = bt.id"]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        resultSet = [db executeQuery:@"select a.id as oldBillId, b.id as newBillId from tmpTable as a, tmpTable as b where a.userid = ? and b.userid = ? and a.name = b.name", userId, currentUserId];
        
        NSMutableArray *repeatedBillIds = [NSMutableArray array];
        while ([resultSet next]) {
            NSString *oldBillId = [resultSet stringForColumn:@"oldBillId"];
            if (oldBillId) {
                [repeatedBillIds addObject:[NSString stringWithFormat:@"'%@'", oldBillId]];
            }
        }
        [resultSet close];
        
        sql = [@"update bk_user_bill set cuserid = ?, iversion = ?, cwritedate = ?, operatortype = 1 where cuserid = ?" mutableCopy];
        if (repeatedBillIds.count) {
            [sql appendFormat:@" and cbillid not in (%@)", [repeatedBillIds componentsJoinedByString:@","]];
        }
        
        if (![db executeUpdate:sql, currentUserId, @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], userId]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
    }];
}

@end
