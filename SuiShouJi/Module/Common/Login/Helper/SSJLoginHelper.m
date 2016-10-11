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
        
        // 查询名称重复的资金账户id，需要排除信用卡的账户，因为同一账户可以有多个重名的信用卡账户
        FMResultSet *resultSet = [db executeQuery:@"select a.cfundid as oldFundId, b.cfundid as newFundId from bk_fund_info as a, bk_fund_info as b where a.cuserid = ? and b.cuserid = ? and a.cacctname = b.cacctname and cparent <> '3'", userId, currentUserId];
        
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
        
        // 查询名称重复的账本id
        resultSet = [db executeQuery:@"select a.cbooksid as oldBooksId, b.cbooksid as newBooksId from bk_books_type as a, bk_books_type as b where a.cuserid = ? and b.cuserid = ? and a.cbooksname = b.cbooksname", userId, currentUserId];
        
        NSMutableArray *repeatedBooksIds = [NSMutableArray array];
        NSMutableDictionary *booksIdMapping = [NSMutableDictionary dictionary];
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
        
        // 将未重名的账本转移到登录账户下
        sql = [@"update bk_books_type set cuserid = ?, iversion = ?, cwritedate = ?, operatortype = 1 where cuserid = ?" mutableCopy];
        if (repeatedBooksIds.count) {
            [sql appendFormat:@" and cbooksid not in (%@)", [repeatedBooksIds componentsJoinedByString:@","]];
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
        
        // 创建个临时表存储类别ID、类别名称、userid，再从临时表中查询名称重复的收支类别id
        if (![db executeUpdate:@"create temporary table if not exists tmpTable (id text, name text, userid text, primary key(id, userid))"]) {
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
        NSMutableDictionary *billIdMapping = [NSMutableDictionary dictionary];
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
        
        // 把名称未重复的收支类型转移到登录账户下
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
        
        // 把普通流水转移到登录账户下
        if (![db executeUpdate:@"update bk_user_charge set cuserid = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cuserid = ? and ibillid not in (select id from bk_bill_type where istate = 2)", currentUserId, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), userId]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 转移转账流水
        resultSet = [db executeQuery:@"select ichargeid, cwritedate from bk_user_charge where cuserid = ? and (ibillid = 3 or ibillid = 4)", userId];
        while ([resultSet next]) {
            NSString *chargeID = [resultSet stringForColumn:@"ichargeid"];
            NSString *writeDateStr = [resultSet stringForColumn:@"cwritedate"];
            NSDate *writeDate = [[NSDate dateWithString:writeDateStr formatString:@"yyyy-MM-dd HH:mm:ss.SSS"] dateByAddingSeconds:1];
            writeDateStr = [writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            [db executeUpdate:@"update bk_user_charge set cuserid = ?, cwritedate = ?, iversion = ?, operatortype = 1 where operatortype <> 2 and ichargeid = ?", currentUserId, writeDateStr, @(SSJSyncVersion()), chargeID];
        }
        
        //
        __block BOOL successfull = YES;
        [fundIdMapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *oldFundId = key;
            NSString *newFundId = obj;
            successfull = [db executeUpdate:@"update bk_user_charge set ifunsid = ? where ifunsid = ?", newFundId, oldFundId];
        }];
        
        if (!successfull) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        [booksIdMapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *oldBooksId = key;
            NSString *newBooksId = obj;
            successfull = [db executeUpdate:@"update bk_user_charge set cbooksid = ? where cbooksid = ?", newBooksId, oldBooksId];
        }];
        
        if (!successfull) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        [billIdMapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *oldBillId = key;
            NSString *newBillId = obj;
            successfull = [db executeUpdate:@"update bk_user_charge set ibillid = ? where ibillid = ?", newBillId, oldBillId];
        }];
        
        if (!successfull) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

@end
