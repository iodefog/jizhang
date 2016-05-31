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
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *chargeList = [NSMutableArray array];
        FMResultSet *chargeResult = [db executeQuery:@"select a.* , b.CCOIN , b.CNAME , b.CCOLOR , b.ITYPE as INCOMEOREXPENSE , b.ID from BK_CHARGE_PERIOD_CONFIG as a, BK_BILL_TYPE as b where CUSERID = ? and OPERATORTYPE != 2 and a.IBILLID = b.ID order by A.ITYPE ASC , A.IMONEY DESC",userid];
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
    return item;
}

@end
