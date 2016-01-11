//
//  SSJDailySumChargeTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDailySumChargeTable.h"
#import "SSJSyncTable.h"

@interface SSJDailySumChargeTableModel : NSObject

//  流水日期
@property (nonatomic, copy) NSString *billDate;

//  支出
@property (nonatomic) double expenceAmount;

//  收入
@property (nonatomic) double incomeAmount;

@end

@implementation SSJDailySumChargeTableModel

@end

@implementation SSJDailySumChargeTable

+ (BOOL)updateDailySumChargeInDatabase:(FMDatabase *)db {
    int lastSyncVersion = [SSJSyncTable lastSuccessSyncVersionInDatabase:db];
    FMResultSet *result = [db executeQuery:@"select A.CBILLDATE, B.ITYPE, sum(A.IMONEY) from BK_USER_CHARGE as A, BK_BILL_TYPE as B where A.IBILLID = B.ID and A.IVERSION > ? and A.CUSERID = ? group by A.CBILLDATE, B.ITYPE order by A.CBILLDATE", @(lastSyncVersion), SSJUSERID()];
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
        
        SSJDailySumChargeTableModel *model = dailyChargeInfo[billDate];
        if (!model) {
            model = [[SSJDailySumChargeTableModel alloc] init];
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
        SSJDailySumChargeTableModel *model = obj;
        FMResultSet *result = [db executeQuery:@"select count(*) from BK_DAILYSUM_CHARGE where CBILLDATE = ?", model.billDate];
        if (!result) {
            SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
            success = NO;
            *stop = YES;
            return;
        }
        
        
    }];
    
    return YES;
}

@end
