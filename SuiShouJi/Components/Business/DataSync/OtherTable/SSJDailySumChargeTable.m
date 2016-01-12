//
//  SSJDailySumChargeTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDailySumChargeTable.h"
#import "SSJSyncTable.h"

@interface __SSJDailySumChargeTableModel : NSObject

//  流水日期
@property (nonatomic, copy) NSString *billDate;

//  支出
@property (nonatomic) double expenceAmount;

//  收入
@property (nonatomic) double incomeAmount;

@end

@implementation __SSJDailySumChargeTableModel

@end

@implementation SSJDailySumChargeTable

+ (BOOL)updateDailySumChargeInDatabase:(FMDatabase *)db {
    int lastSyncVersion = [SSJSyncTable lastSuccessSyncVersionInDatabase:db];
    FMResultSet *result = [db executeQuery:@"select A.CBILLDATE, B.ITYPE, sum(A.IMONEY) from BK_USER_CHARGE as A, BK_BILL_TYPE as B where A.IBILLID = B.ID and A.IVERSION > ? and A.CUSERID = ? and A.OPERATORTYPE <> 2 group by A.CBILLDATE, B.ITYPE order by A.CBILLDATE", @(lastSyncVersion), SSJUSERID()];
    if (!result) {
        SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return NO;
    }
    
    NSMutableDictionary *dailyChargeInfo = [NSMutableDictionary dictionary];
    while ([result next]) {
        NSString *billDate = [result stringForColumnIndex:0];
        if (billDate.length == 0) {
            continue;
        }
        
        __SSJDailySumChargeTableModel *model = dailyChargeInfo[billDate];
        if (!model) {
            model = [[__SSJDailySumChargeTableModel alloc] init];
        }
        model.billDate = billDate;
        
        double money = [result doubleForColumnIndex:2];
        
        //  0收入 1支出
        int type = [result intForColumnIndex:1];
        if (type == 0) {
            model.incomeAmount = money;
        } else if (type == 1) {
            model.expenceAmount = money;
        } else {
            continue;
        }
        [dailyChargeInfo setObject:model forKey:billDate];
    }
    
    __block BOOL success = YES;
    [dailyChargeInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        __SSJDailySumChargeTableModel *model = obj;
        FMResultSet *result = [db executeQuery:@"select count(*) from BK_DAILYSUM_CHARGE where CBILLDATE = ?", model.billDate];
        if (!result) {
            SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
            success = NO;
            *stop = YES;
            return;
        }
        
        [result next];
        if ([result intForColumnIndex:0] > 0) {
            if (![db executeUpdate:@"update BK_DAILYSUM_CHARGE set EXPENCEAMOUNT = (EXPENCEAMOUNT + ?), INCOMEAMOUNT = (INCOMEAMOUNT + ?), SUMAMOUNT = (SUMAMOUNT + ?) where CBILLDATE = ?", model.expenceAmount, model.incomeAmount, (model.incomeAmount - model.expenceAmount), model.billDate]) {
                success = NO;
                *stop = YES;
            }
        } else {
            if (![db executeUpdate:@"insert into BK_DAILYSUM_CHARGE (CBILLDATE, EXPENCEAMOUNT, INCOMEAMOUNT, SUMAMOUNT) values (?, ?, ?, ?)", model.billDate, model.expenceAmount, model.incomeAmount, (model.incomeAmount - model.expenceAmount)]) {
                success = NO;
                *stop = YES;
            }
        }
    }];
    
    return success;
}

@end
