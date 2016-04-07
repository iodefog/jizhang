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

+ (BOOL)updateBalanceForUserId:(NSString *)userId inDatabase:(FMDatabase *)db {
    //  清空资金帐户余额表，再根据用户资金帐户表重新创建记录
    if (![db executeUpdate:@"delete from bk_funs_acct where cuserid = ?", userId]) {
        return NO;
    }
    
    if (![db executeUpdate:@"insert into bk_funs_acct (cuserid, cfundid, ibalance) select cuserid, cfundid, 0 from bk_fund_info where cuserid = ?", userId]) {
        return NO;
    }
    
    //  从截止到今天有效的记账流水中，查询各个资金帐户的总收入、总支出
    __block FMResultSet *result = [db executeQuery:@"select A.IFUNSID, sum(A.IMONEY), B.ITYPE from BK_USER_CHARGE as A, BK_BILL_TYPE as B where A.IBILLID = B.ID and A.CUSERID = ? and A.OPERATORTYPE <> 2 and a.cbilldate <= ? group by A.IFUNSID, B.ITYPE", userId, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]];
    if (!result) {
        SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return NO;
    }
    
    //  创建字典，key是资金帐户id，value是金额变化
    NSMutableDictionary *moneyInfo = [NSMutableDictionary dictionary];
    
    while ([result next]) {
        int type = [result intForColumn:@"ITYPE"];
        double money = [result doubleForColumn:@"sum(A.IMONEY)"];
        NSString *fundId = [result stringForColumn:@"IFUNSID"];
        
        double sum = [[moneyInfo objectForKey:fundId] doubleValue];
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
    
    //  遍历moneyInfo，根据key（资金帐户id）查询BK_FUNS_ACCT表中是否存在相应的记录，存在就修改为最新的金额
    [moneyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![db executeUpdate:@"update BK_FUNS_ACCT set IBALANCE = ? where CFUNDID = ? and CUSERID = ?", obj, key, userId]) {
            SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
            success = NO;
            *stop = YES;
        }
    }];
    
    return success;
}

@end
