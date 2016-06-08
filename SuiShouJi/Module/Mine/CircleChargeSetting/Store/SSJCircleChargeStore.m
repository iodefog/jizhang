//
//  SSJCircleChargeStore.m
//  SuiShouJi
//
//  Created by ricky on 16/5/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCircleChargeStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJCircleChargeStore
+ (void)queryForChargeListWithSuccess:(void(^)(NSArray<SSJBillingChargeCellItem *> *result))success
                              failure:(void (^)(NSError *error))failure {
    __block NSString *booksId = SSJGetCurrentBooksType();
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *chargeList = [NSMutableArray array];
        FMResultSet *chargeResult = [db executeQuery:@"select a.* , b.CCOIN , b.CNAME , b.CCOLOR , b.ITYPE as INCOMEOREXPENSE , b.ID , c.cbooksname from BK_CHARGE_PERIOD_CONFIG as a, BK_BILL_TYPE as b , bk_books_type as c where a.CUSERID = ? and a.OPERATORTYPE != 2 and a.IBILLID = b.ID and c.cbooksid = ? and a.cbooksid = c.cbooksid order by A.ITYPE ASC , A.IMONEY DESC",userid,booksId];
        if (!chargeResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([chargeResult next]) {
            [chargeList addObject:[self chargeItemWithResultSet:chargeResult inDatabase:db]];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(chargeList);
            });
        }
    }];
}

+ (void)queryDefualtItemWithIncomeOrExpence:(BOOL)incomeOrExpence
                                    Success:(void(^)(SSJBillingChargeCellItem *item))success
                              failure:(void (^)(NSError *error))failure {
    __block NSString *booksId = SSJGetCurrentBooksType();
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc]init];
        item.billDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
        item.billId = [db stringForQuery:@"select a.id from bk_bill_type as a , bk_user_bill as b where b.iorder = 1 and b.istate = 1 and b.cuserid = ? and a.id = b.cbillid and a.itype = ?",userid,@(incomeOrExpence)];
        item.typeName = [db stringForQuery:@"select cname from bk_bill_type where id = ?",item.billId];
        item.booksName = [db stringForQuery:@"select cbooksname from bk_books_type where cbooksid = ?",booksId];
        item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cuserid = ? order by iorder limit 1",userid];
        item.fundId = [db stringForQuery:@"select cfundid from bk_fund_info where cuserid = ? order by iorder limit 1",userid];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(item);
            });
        }

    }];
}

+ (SSJBillingChargeCellItem *)chargeItemWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
    item.imageName = [set stringForColumn:@"CCOIN"];
    item.typeName = [set stringForColumn:@"CNAME"];
    item.money = [set stringForColumn:@"IMONEY"];
    item.colorValue = [set stringForColumn:@"CCOLOR"];
    item.incomeOrExpence = [set boolForColumn:@"ITYPE"];
    item.ID = [set stringForColumn:@"ICHARGEID"];
    item.fundId = [set stringForColumn:@"IFUNSID"];
    item.editeDate = [set stringForColumn:@"CWRITEDATE"];
    item.billId = [set stringForColumn:@"IBILLID"];
    item.chargeImage = [set stringForColumn:@"CIMGURL"];
    item.chargeThumbImage = [set stringForColumn:@"THUMBURL"];
    item.chargeMemo = [set stringForColumn:@"CMEMO"];
    item.configId = [set stringForColumn:@"ICONFIGID"];
    item.billDate = [set stringForColumn:@"CBILLDATE"];
    item.booksName = [set stringForColumn:@"CBOOKSID"];
    return item;
}

@end
