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
NSString *const SSJOrginalChargeArrKey = @"SSJOrginalChargeArrKey";
NSString *const SSJNewAddChargeArrKey = @"SSJNewAddChargeArrKey";
NSString *const SSJChargeCountSummaryKey = @"SSJChargeCountSummaryKey";
NSString *const SSJDateStartIndexDicKey = @"SSJDateStartIndexDicKey";

@implementation SSJBookKeepingHomeHelper

+ (void)queryForChargeListWithSuccess:(void(^)(NSArray<SSJBillingChargeCellItem *> *result))success
                              failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *chargeList = [NSMutableArray array];
        FMResultSet *chargeResult = [db executeQuery:@"SELECT A.CBILLDATE , A.IMONEY , A.ICHARGEID , A.IBILLID , A.CWRITEDATE  ,A.IFUNSID , A.CUSERID , A.CIMGURL ,  A.THUMBURL ,A.CMEMO , A.ICONFIGID , B.CNAME, B.CCOIN, B.CCOLOR, B.ITYPE , C.ITYPE AS CHARGECIRCLE , C.OPERATORTYPE  AS CONFIGOPERATORTYPE FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE  ,IFUNSID , CUSERID , CMEMO ,  CIMGURL ,  THUMBURL , ICONFIGID FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE , IFUNSID , CUSERID , CMEMO ,  CIMGURL , THUMBURL , ICONFIGID FROM BK_USER_CHARGE WHERE CBILLDATE IN (SELECT CBILLDATE FROM BK_DAILYSUM_CHARGE ORDER BY CBILLDATE DESC)  AND OPERATORTYPE != 2) WHERE IBILLID != '1' AND IBILLID != '2' AND IBILLID != '3' AND IBILLID != '4' AND CUSERID = ? UNION SELECT * FROM (SELECT CBILLDATE , SUMAMOUNT AS IMONEY , ICHARGEID , IBILLID , '3'||substr(cwritedate,2) AS CWRITEDATE , IFUNSID , CUSERID , '' AS CMEMO , '' AS CIMGURL , '' AS THUMBURL , '' AS ICONFIGID FROM BK_DAILYSUM_CHARGE WHERE CUSERID = ? ORDER BY CBILLDATE DESC)) AS A LEFT JOIN BK_BILL_TYPE AS B ON A.IBILLID = B.ID LEFT JOIN BK_CHARGE_PERIOD_CONFIG AS C ON A.ICONFIGID = C.ICONFIGID WHERE A.CBILLDATE <= ?  ORDER BY A.CBILLDATE DESC , A.CWRITEDATE DESC",userid,userid,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
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

+ (void)queryForChargeListExceptNewCharge:(NSArray *)newCharge
                              Success:(void(^)(NSDictionary *result))success
                             failure:(void (^)(NSError *error))failure
{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *originalChargeArr = [NSMutableArray array];
        NSMutableArray *newAddChargeArr = [NSMutableArray array];
        NSMutableDictionary *summaryDic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        NSMutableDictionary *startIndex = [NSMutableDictionary dictionary];
        NSString *lastDate = @"";
        int count = 0;
        int chargeCount = 0;
        FMResultSet *chargeResult = [db executeQuery:@"SELECT A.CBILLDATE , A.IMONEY , A.ICHARGEID , A.IBILLID , A.CWRITEDATE  ,A.IFUNSID , A.CUSERID , A.CIMGURL ,  A.THUMBURL ,A.CMEMO , A.ICONFIGID , A.OPERATORTYPE AS CHARGEOPERATORTYPE , B.CNAME, B.CCOIN, B.CCOLOR, B.ITYPE , C.ITYPE AS CHARGECIRCLE , C.OPERATORTYPE  AS CONFIGOPERATORTYPE FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE  ,IFUNSID , CUSERID , CMEMO ,  CIMGURL ,  THUMBURL , ICONFIGID , OPERATORTYPE FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE , IFUNSID , CUSERID , CMEMO ,  CIMGURL , THUMBURL , ICONFIGID , OPERATORTYPE FROM BK_USER_CHARGE WHERE CBILLDATE IN (SELECT CBILLDATE FROM BK_DAILYSUM_CHARGE ORDER BY CBILLDATE DESC)  AND OPERATORTYPE != 2) WHERE IBILLID != '1' AND IBILLID != '2' AND IBILLID != '3' AND IBILLID != '4' AND CUSERID = ? UNION SELECT * FROM (SELECT CBILLDATE , SUMAMOUNT AS IMONEY , ICHARGEID , IBILLID , '3'||substr(cwritedate,2) AS CWRITEDATE , IFUNSID , CUSERID , '' AS CMEMO , '' AS CIMGURL , '' AS THUMBURL , '' AS ICONFIGID , 0 AS OPERATORTYPE  FROM BK_DAILYSUM_CHARGE WHERE CUSERID = ? ORDER BY CBILLDATE DESC)) AS A LEFT JOIN BK_BILL_TYPE AS B ON A.IBILLID = B.ID LEFT JOIN BK_CHARGE_PERIOD_CONFIG AS C ON A.ICONFIGID = C.ICONFIGID WHERE A.CBILLDATE <= ?  ORDER BY A.CBILLDATE DESC , A.CWRITEDATE DESC",userid,userid,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
        if (!chargeResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([chargeResult next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [chargeResult stringForColumn:@"CCOIN"];
            item.typeName = [chargeResult stringForColumn:@"CNAME"];
            item.money = [chargeResult stringForColumn:@"IMONEY"];
            item.colorValue = [chargeResult stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [chargeResult boolForColumn:@"ITYPE"];
            item.ID = [chargeResult stringForColumn:@"ICHARGEID"];
            item.fundId = [chargeResult stringForColumn:@"IFUNSID"];
            item.editeDate = [chargeResult stringForColumn:@"CWRITEDATE"];
            item.billId = [chargeResult stringForColumn:@"IBILLID"];
            item.chargeImage = [chargeResult stringForColumn:@"CIMGURL"];
            item.chargeThumbImage = [chargeResult stringForColumn:@"THUMBURL"];
            item.chargeMemo = [chargeResult stringForColumn:@"CMEMO"];
            item.configId = [chargeResult stringForColumn:@"ICONFIGID"];
            item.operatorType = [chargeResult intForColumn:@"CHARGEOPERATORTYPE"];
            int configOperatorType = [chargeResult intForColumn:@"CONFIGOPERATORTYPE"];
            item.billDate = [chargeResult stringForColumn:@"CBILLDATE"];
            if ([item.billId isEqualToString:@"-1"]) {
                [startIndex setObject:@(count) forKey:item.billDate];
            }
            if (![item.billDate isEqualToString:lastDate]) {
                lastDate = item.billDate;
                chargeCount = 0;
                [summaryDic setValue:@(chargeCount) forKey:item.billDate];
            }else{
                chargeCount = [[summaryDic valueForKey:item.billDate] intValue] + 1;
                [summaryDic setValue:@(chargeCount) forKey:item.billDate];
            }
            item.chargeIndex = count;
            if (configOperatorType == 2) {
                item.chargeCircleType = - 1;
            }else{
                item.chargeCircleType = [chargeResult intForColumn:@"CHARGECIRCLE"];
            }
            if ([item.configId isEqualToString:@""] || item.configId == nil) {
                item.chargeCircleType = - 1;
            }
            for (int i = 0; i < newCharge.count; i++) {
                SSJBillingChargeCellItem *newItem = [newCharge objectAtIndex:i];
                if ([item.ID isEqualToString:newItem.ID]) {
                    [newAddChargeArr addObject:item];
                }
            }
            [originalChargeArr addObject:item];
            count++;
        }
        for (int i = 0; i < newAddChargeArr.count; i++) {
            SSJBillingChargeCellItem *item = [newAddChargeArr objectAtIndex:i];
            int chargeCount = [[summaryDic valueForKey:item.billDate] intValue];
            [summaryDic setValue:@(chargeCount - 1) forKey:item.billDate];
        }
        [tempDic setObject:originalChargeArr forKey:SSJOrginalChargeArrKey];
        [tempDic setObject:newAddChargeArr forKey:SSJNewAddChargeArrKey];
        [tempDic setObject:summaryDic forKey:SSJChargeCountSummaryKey];
        [tempDic setObject:startIndex forKey:SSJDateStartIndexDicKey];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempDic);
            });
        }
    }];
}

+ (void)queryForIncomeAndExpentureSumWithMonth:(long)month
                                          Year:(long)year
                                       Success:(void(^)(NSDictionary *result))success
                                       failure:(void (^)(NSError *error))failure {
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
