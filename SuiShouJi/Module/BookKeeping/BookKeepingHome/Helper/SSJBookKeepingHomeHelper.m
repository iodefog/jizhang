//
//  SSJBookKeepingHomeHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/3/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeHelper.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJDatabaseQueue.h"

NSString *const SSJIncomeSumlKey = @"SSJIncomeSumlKey";
NSString *const SSJExpentureSumKey = @"SSJExpentureSumKey";

@implementation SSJBookKeepingHomeHelper

+ (void)queryForChargeListWithSuccess:(void(^)(NSArray<SSJBillingChargeCellItem *> *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *chargeList = [NSMutableArray array];
        FMResultSet *chargeResult = [db executeQuery:@"SELECT A.CBILLDATE , A.IMONEY , A.ICHARGEID , A.IBILLID , A.CWRITEDATE  ,A.IFUNSID , A.CUSERID , A.CIMGURL ,  A.THUMBURL ,A.CMEMO , A.ICONFIGID , B.CNAME, B.CCOIN, B.CCOLOR, B.ITYPE , C.ITYPE AS CHARGECIRCLE , C.OPERATORTYPE  AS CONFIGOPERATORTYPE FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE  ,IFUNSID , CUSERID , CMEMO ,  CIMGURL ,  THUMBURL , ICONFIGID FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE , IFUNSID , CUSERID , CMEMO ,  CIMGURL , THUMBURL , ICONFIGID FROM BK_USER_CHARGE WHERE CBILLDATE IN (SELECT CBILLDATE FROM BK_DAILYSUM_CHARGE ORDER BY CBILLDATE DESC)  AND OPERATORTYPE != 2) WHERE IBILLID != '1' AND IBILLID != '2' AND IBILLID != '3' AND IBILLID != '4' AND CUSERID = ? UNION SELECT * FROM (SELECT CBILLDATE , SUMAMOUNT AS IMONEY , ICHARGEID , IBILLID , '1'||substr(cwritedate,2) AS CWRITEDATE , IFUNSID , CUSERID , '' AS CMEMO , '' AS CIMGURL , '' AS THUMBURL , '' AS ICONFIGID FROM BK_DAILYSUM_CHARGE WHERE CUSERID = ? ORDER BY CBILLDATE DESC)) AS A LEFT JOIN BK_BILL_TYPE AS B ON A.IBILLID = B.ID LEFT JOIN BK_CHARGE_PERIOD_CONFIG AS C ON A.ICONFIGID = C.ICONFIGID WHERE A.CBILLDATE <= ?  ORDER BY A.CBILLDATE DESC , A.CWRITEDATE asc",userid,userid,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
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

+ (void)queryForIncomeAndExpentureSumWithMonth:(long)month Year:(long)year Success:(void(^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableDictionary *SumDic = [NSMutableDictionary dictionary];
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"SELECT SUM(INCOMEAMOUNT) , SUM(EXPENCEAMOUNT) FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE LIKE '%04ld-%02ld-__' AND CUSERID = '%@' AND CBILLDATE <= '%@'", year,month,userid,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]]];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([resultSet next]) {
            double incomeSum = [resultSet doubleForColumn:@"SUM(INCOMEAMOUNT)"];
            double expentureSum = [resultSet doubleForColumn:@"SUM(EXPENCEAMOUNT)"];
            [SumDic setObject:@(incomeSum) forKey:SSJIncomeSumlKey];
            [SumDic setObject:@(expentureSum) forKey:SSJExpentureSumKey];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(SumDic);
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
    int configOperatorType = [set intForColumn:@"CONFIGOPERATORTYPE"];
    item.billDate = [set stringForColumn:@"CBILLDATE"];
    if (configOperatorType == 2) {
        item.chargeCircleType = - 1;
    }else{
        item.chargeCircleType = [set intForColumn:@"CHARGECIRCLE"];
    }
    if ([item.configId isEqualToString:@""] || item.configId == nil) {
        item.chargeCircleType = - 1;
    }
    return item;
}
@end
