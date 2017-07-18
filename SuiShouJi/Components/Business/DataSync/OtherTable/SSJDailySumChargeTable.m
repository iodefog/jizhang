//
//  SSJDailySumChargeTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDailySumChargeTable.h"
#import "SSJUserTableManager.h"
#import "SSJSyncTable.h"
#import "FMDB.h"

//  每日收支流水模型
@interface __SSJDailySumChargeTableModel : NSObject

//  流水日期
@property (nonatomic, copy) NSString *billDate;

//  账本id
@property (nonatomic, copy) NSString *booksId;

//  支出
@property (nonatomic) double expenceAmount;

//  收入
@property (nonatomic) double incomeAmount;

@end

@implementation __SSJDailySumChargeTableModel

@end

@implementation SSJDailySumChargeTable

+ (BOOL)updateDailySumChargeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"delete from BK_DAILYSUM_CHARGE where cuserid = ?", userId]) {
        return NO;
    }
    
    //  查询当前用户不同日期、账本的收入、支出总金额
    __block FMResultSet *result = [db executeQuery:@"select A.CBILLDATE, B.ITYPE, sum(A.IMONEY), A.CBOOKSID, A.ICHARGEID from BK_USER_CHARGE as A, BK_USER_BILL_TYPE as B where A.IBILLID = B.CBILLID and A.CUSERID = ? and A.OPERATORTYPE <> 2 and A.cbilldate <= datetime('now', 'localtime') group by A.CBILLDATE, A.CBOOKSID, B.ITYPE", userId];
    if (!result) {
        SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return NO;
    }
    
    NSMutableDictionary *dailyChargeInfo = [NSMutableDictionary dictionary];
    while ([result next]) {
        NSString *billDate = [result stringForColumnIndex:0];
        NSString *booksId = [result stringForColumnIndex:3];
//        NSString *chargeId = [result stringForColumnIndex:4];
        if (billDate.length == 0 || booksId.length == 0) {
//            SSJPRINT(@"错误：流水billdate或booksid为空，流水id：%@；booksid：%@", chargeId, booksId);
            continue;
        }
        
        NSString *key = [NSString stringWithFormat:@"%@-%@", billDate, booksId];
        __SSJDailySumChargeTableModel *model = dailyChargeInfo[key];
        if (!model) {
            model = [[__SSJDailySumChargeTableModel alloc] init];
        }
        model.billDate = billDate;
        model.booksId = booksId;
        
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
        [dailyChargeInfo setObject:model forKey:key];
    }
    
    [result close];
    
    __block BOOL success = YES;
    
    [dailyChargeInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        __SSJDailySumChargeTableModel *model = obj;
        
        if (![db executeUpdate:@"insert into BK_DAILYSUM_CHARGE (CBILLDATE, EXPENCEAMOUNT, INCOMEAMOUNT, SUMAMOUNT, CUSERID, cwritedate, cbooksid) values (?, ?, ?, ?, ?, ?, ?)", model.billDate, @(model.expenceAmount), @(model.incomeAmount), @(model.incomeAmount - model.expenceAmount), userId, [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], model.booksId]) {
            success = NO;
            *stop = YES;
        }
    }];
    
    return success;
}

@end
