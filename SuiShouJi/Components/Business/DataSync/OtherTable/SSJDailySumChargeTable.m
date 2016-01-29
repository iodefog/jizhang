//
//  SSJDailySumChargeTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDailySumChargeTable.h"
#import "SSJSyncTable.h"
#import "FMDB.h"
#import "SSJDataSyncHelper.h"

//  每日收支流水模型
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
    __block FMResultSet *result = [db executeQuery:@"select A.CBILLDATE, B.ITYPE, sum(A.IMONEY) from BK_USER_CHARGE as A, BK_BILL_TYPE as B where A.IBILLID = B.ID and A.CUSERID = ? and A.OPERATORTYPE <> 2 and B.istate <> 2 group by A.CBILLDATE, B.ITYPE order by A.CBILLDATE", SSJCurrentSyncUserId()];
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
    
    [result close];
    
    __block BOOL success = YES;
    [dailyChargeInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        __SSJDailySumChargeTableModel *model = obj;
        result = [db executeQuery:@"select count(*) from BK_DAILYSUM_CHARGE where CBILLDATE = ? and CUSERID = ?", model.billDate, SSJCurrentSyncUserId()];
        if (!result) {
            SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
            success = NO;
            *stop = YES;
            return;
        }
        
        [result next];
        if ([result intForColumnIndex:0] > 0) {
            if (![db executeUpdate:@"update BK_DAILYSUM_CHARGE set EXPENCEAMOUNT = ?, INCOMEAMOUNT = ?, SUMAMOUNT = ?, ibillid = -1, cwritedate = ? where CBILLDATE = ? and CUSERID = ?", @(model.expenceAmount), @(model.incomeAmount), @(model.incomeAmount - model.expenceAmount), [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], model.billDate, SSJCurrentSyncUserId()]) {
                success = NO;
                *stop = YES;
            }
        } else {
            if (![db executeUpdate:@"insert into BK_DAILYSUM_CHARGE (CBILLDATE, EXPENCEAMOUNT, INCOMEAMOUNT, SUMAMOUNT, CUSERID, ibillid, cwritedate) values (?, ?, ?, ?, ?, -1, ?)", model.billDate, @(model.expenceAmount), @(model.incomeAmount), @(model.incomeAmount - model.expenceAmount), SSJCurrentSyncUserId(), [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
                success = NO;
                *stop = YES;
            }
        }
    }];
    
    [result close];
    
    if (!success) {
        return NO;
    }
    
    //  将没有流水的日期从BK_DAILYSUM_CHARGE表中删除
    NSArray *allBillDates = [dailyChargeInfo allKeys];
    NSMutableArray *billDateSet = [NSMutableArray arrayWithCapacity:allBillDates.count];
    for (NSString *billdate in allBillDates) {
        [billDateSet addObject:[NSString stringWithFormat:@"'%@'", billdate]];
    }
    NSString *billDateStr = [billDateSet componentsJoinedByString:@", "];
    
    return [db executeUpdate:[NSString stringWithFormat:@"delete from BK_DAILYSUM_CHARGE where cbilldate not in (%@)", billDateStr]];
}

@end
