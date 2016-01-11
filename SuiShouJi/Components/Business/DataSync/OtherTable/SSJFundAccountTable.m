//
//  SSJFundAccountTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundAccountTable.h"
#import "SSJSyncTable.h"

@implementation SSJFundAccountTable

+ (BOOL)updateBalanceInDatabase:(FMDatabase *)db {
    int lastSyncVersion = [SSJSyncTable lastSuccessSyncVersionInDatabase:db];
    FMResultSet *result = [db executeQuery:@"select A.IFID, sum(A.IMONEY), B.ITYPE from BK_USER_CHARGE as A, BK_BILL_TYPE as B where A.IBILLID = B.ID and A.IVERSION > ? and A.CUSERID = ? group by A.IFID, B.ITYPE order by A.IFID", @(lastSyncVersion), SSJUSERID()];
    if (!result) {
        SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return NO;
    }
    
    double sum = 0;
    NSString *tempFundId = nil;
    
    //  创建字典，key是资金帐户id，value是金额变化
    NSMutableDictionary *moneyInfo = [NSMutableDictionary dictionary];
    
    while ([result next]) {
        int type = [result intForColumn:@"ITYPE"];
        double money = [result doubleForColumn:@"IMONEY"];
        NSString *fundId = [result stringForColumn:@"IFID"];
        if (!fundId.length) {
            continue;
        }
        
        if (![tempFundId isEqualToString:fundId]) {
            sum = 0;
            tempFundId = fundId;
        }
        
        //  0收入 1支出
        if (type == 0) {
            sum += money;
        } else if (type == 1) {
            sum -= money;
        } else {
            continue;
        }
        
        [moneyInfo setObject:@(sum) forKey:fundId];
    }
    
    __block BOOL success = YES;
    
    //  遍历moneyInfo，根据key（资金帐户id）查询BK_FUNS_ACCT表中是否存在相应的记录，存在就修改为最新的金额，反之则新建个记录
    [moneyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        FMResultSet *result = [db executeQuery:@"select count(*) from BK_FUNS_ACCT where CFUNDID = ?", key];
        if (!result) {
            success = NO;
            *stop = YES;
            return;
        }
        
        [result next];
        if ([result intForColumnIndex:0] > 0) {
            if (![db executeUpdate:@"update BK_FUNS_ACCT set IBALANCE = (IBALANCE + ?) where CFUNDID = ?", obj, key]) {
                SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
                success = NO;
                *stop = YES;
            }
        } else {
            if (![db executeUpdate:@"insert into BK_FUNS_ACCT (CUSERID, CFUNDID, IBALANCE) values (?, ?, ?)", SSJUSERID(), key, obj]) {
                SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
                success = NO;
                *stop = YES;
            }
        }
    }];
    
    return success;
}

@end
