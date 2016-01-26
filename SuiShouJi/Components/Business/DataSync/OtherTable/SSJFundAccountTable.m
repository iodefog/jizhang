//
//  SSJFundAccountTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundAccountTable.h"
#import "FMDB.h"

@implementation SSJFundAccountTable

+ (BOOL)updateBalanceInDatabase:(FMDatabase *)db {
    __block FMResultSet *result = [db executeQuery:@"select A.IFUNSID, sum(A.IMONEY), B.ITYPE from BK_USER_CHARGE as A, BK_BILL_TYPE as B where A.IBILLID = B.ID and A.CUSERID = ? and A.OPERATORTYPE <> 2 group by A.IFUNSID, B.ITYPE order by A.IFUNSID", SSJUSERID()];
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
        double money = [result doubleForColumn:@"sum(A.IMONEY)"];
        NSString *fundId = [result stringForColumn:@"IFUNSID"];
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
    
    [result close];
    
    __block BOOL success = YES;
    
    //  遍历moneyInfo，根据key（资金帐户id）查询BK_FUNS_ACCT表中是否存在相应的记录，存在就修改为最新的金额，反之则新建个记录
    [moneyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        result = [db executeQuery:@"select count(*) from BK_FUNS_ACCT where CFUNDID = ? and CUSERID = ?", key, SSJUSERID()];
        if (!result) {
            success = NO;
            *stop = YES;
            return;
        }
        
        [result next];
        if ([result intForColumnIndex:0] > 0) {
            if (![db executeUpdate:@"update BK_FUNS_ACCT set IBALANCE = ? where CFUNDID = ? and CUSERID = ?", obj, key, SSJUSERID()]) {
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
    
    
    result = [db executeQuery:@"select cfundid, cuserid from BK_FUND_INFO where cuserid = ?", SSJUSERID()];
    while ([result next]) {
        NSString *fundId = [result stringForColumn:@"cfundid"];
        NSString *cuserId = [result stringForColumn:@"cuserid"];
        success = [db executeUpdate:@"insert into BK_FUNS_ACCT (cfundid, cuserid, ibalance) select ?, ?, 0 where not exists (select count(*) from BK_FUNS_ACCT where cfundid = ? and cuserid = ?)", fundId, cuserId, fundId, cuserId];
    }
    
    [result close];
    
    return success;
}

@end
