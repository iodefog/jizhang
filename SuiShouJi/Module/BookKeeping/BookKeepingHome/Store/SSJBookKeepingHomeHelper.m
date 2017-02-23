//
//  SSJBookKeepingHomeHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/3/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeHelper.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJBookKeepingHomeListItem.h"
#import "SSJDatabaseQueue.h"

NSString *const SSJIncomeSumlKey = @"SSJIncomeSumlKey";
NSString *const SSJExpentureSumKey = @"SSJExpentureSumKey";
NSString *const SSJOrginalChargeArrKey = @"SSJOrginalChargeArrKey";
NSString *const SSJNewAddChargeArrKey = @"SSJNewAddChargeArrKey";
NSString *const SSJNewAddChargeSectionArrKey = @"SSJNewAddChargeSectionArrKey";

@implementation SSJBookKeepingHomeHelper

//+ (void)queryForChargeListWithSuccess:(void(^)(NSArray<SSJBillingChargeCellItem *> *result))success
//                              failure:(void (^)(NSError *error))failure {
//    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
//        NSString *userid = SSJUSERID();
//        NSMutableArray *chargeList = [NSMutableArray array];
//        FMResultSet *chargeResult = [db executeQuery:@"SELECT A.CBILLDATE , A.IMONEY , A.ICHARGEID , A.IBILLID , A.CWRITEDATE  ,A.IFUNSID , A.CUSERID , A.CIMGURL ,  A.THUMBURL ,A.CMEMO , A.ICONFIGID , B.CNAME, B.CCOIN, B.CCOLOR, B.ITYPE , C.ITYPE AS CHARGECIRCLE , C.OPERATORTYPE  AS CONFIGOPERATORTYPE FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE  ,IFUNSID , CUSERID , CMEMO ,  CIMGURL ,  THUMBURL , ICONFIGID FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE , IFUNSID , CUSERID , CMEMO ,  CIMGURL , THUMBURL , ICONFIGID FROM BK_USER_CHARGE WHERE CBILLDATE IN (SELECT CBILLDATE FROM BK_DAILYSUM_CHARGE ORDER BY CBILLDATE DESC)  AND OPERATORTYPE != 2) WHERE IBILLID != '1' AND IBILLID != '2' AND IBILLID != '3' AND IBILLID != '4' AND CUSERID = ? UNION SELECT * FROM (SELECT CBILLDATE , SUMAMOUNT AS IMONEY , ICHARGEID , IBILLID , '3'||substr(cwritedate,2) AS CWRITEDATE , IFUNSID , CUSERID , '' AS CMEMO , '' AS CIMGURL , '' AS THUMBURL , '' AS ICONFIGID FROM BK_DAILYSUM_CHARGE WHERE CUSERID = ? ORDER BY CBILLDATE DESC)) AS A LEFT JOIN BK_BILL_TYPE AS B ON A.IBILLID = B.ID LEFT JOIN BK_CHARGE_PERIOD_CONFIG AS C ON A.ICONFIGID = C.ICONFIGID WHERE A.CBILLDATE <= ?  ORDER BY A.CBILLDATE DESC , A.CWRITEDATE DESC",SSJGetCurrentBooksType(),userid,userid,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
//        if (!chargeResult) {
//            if (failure) {
//                SSJDispatch_main_async_safe(^{
//                    failure([db lastError]);
//                });
//            }
//            return;
//        }
//        while ([chargeResult next]) {
//            [chargeList addObject:[self chargeItemWithResultSet:chargeResult inDatabase:db]];
//        }
//        if (success) {
//            SSJDispatch_main_async_safe(^{
//                success(chargeList);
//            });
//        }
//    }];
//}

+ (void)queryForChargeListExceptNewCharge:(NSArray *)newCharge
                              Success:(void(^)(NSDictionary *result))success
                             failure:(void (^)(NSError *error))failure
{
    __block NSString *booksid = SSJGetCurrentBooksType();
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *originalChargeArr = [NSMutableArray array];
        NSMutableArray *newAddChargeArr = [NSMutableArray array];
        NSMutableArray *newSectionArr = [NSMutableArray array];
        NSMutableDictionary *summaryDic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        NSString *lastDate = @"";
        NSInteger totalCount = 0;
        NSString *currentMonth = @"";
        int section = 0;
        int row = 0;
        FMResultSet *chargeResult = [db executeQuery:@"select uc.* , uc.operatortype as chargeoperatortype, bt.cname, bt.ccoin, bt.ccolor, bt.itype from bk_user_charge uc , bk_bill_type bt where uc.ibillid = bt.id and uc.cbilldate <= ? and uc.cuserid = ? and uc.cbooksid = ? and uc.operatortype <> 2 and bt.istate <> 2 order by uc.cbilldate desc , uc.clientadddate desc , uc.cwritedate desc",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"],userid,booksid];
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
            item.operatorType = [chargeResult intForColumn:@"CHARGEOPERATORTYPE"];
            item.billDate = [chargeResult stringForColumn:@"CBILLDATE"];
            item.clientAddDate = [chargeResult stringForColumn:@"clientadddate"];
            item.billDetailDate = [chargeResult stringForColumn:@"cdetaildate"];
            if (![item.billDate isEqualToString:lastDate]) {
                SSJBookKeepingHomeListItem *listItem = [[SSJBookKeepingHomeListItem alloc]init];
                listItem.chargeItems = [NSMutableArray arrayWithCapacity:0];
                listItem.date = item.billDate;
                listItem.totalCount = totalCount;
                if (item.incomeOrExpence) {
                    listItem.balance = - [item.money doubleValue];
                }else{
                    listItem.balance = [item.money doubleValue];
                }
                lastDate = item.billDate;
                row = 0;
                section ++;
                item.chargeIndex = [NSIndexPath indexPathForRow:row inSection:section - 1];
                [listItem.chargeItems addObject:item];
                [summaryDic setObject:@(row + 1) forKey:item.billDate];
                totalCount = totalCount + 2;
                [originalChargeArr addObject:listItem];
                //                [summaryDic setValue:@(chargeCount) forKey:item.billDate];
            }else{
                SSJBookKeepingHomeListItem *listItem = [originalChargeArr lastObject];
                if (item.incomeOrExpence) {
                    listItem.balance = listItem.balance - [item.money doubleValue];
                }else{
                    listItem.balance = listItem.balance + [item.money doubleValue];
                }
                row ++;
                totalCount ++;
                item.chargeIndex = [NSIndexPath indexPathForRow:row inSection:section];
                [listItem.chargeItems addObject:item];
                [summaryDic setObject:@(row + 1) forKey:item.billDate];
            }
            // 将新增的数据独立拿出一个数组
            for (int i = 0; i < newCharge.count; i++) {
                SSJBillingChargeCellItem *newItem = [newCharge ssj_safeObjectAtIndex:i];
                if ([item.ID isEqualToString:newItem.ID]) {
                    [newAddChargeArr addObject:item];
                }
            }
//            count++;
        }
        // 在每日的流水总数中减掉新增的数量
        for (int i = 0; i < newAddChargeArr.count; i++) {
            SSJBillingChargeCellItem *item = [newAddChargeArr ssj_safeObjectAtIndex:i];
            int chargeCount = [[summaryDic valueForKey:item.billDate] intValue];
            [summaryDic setValue:@(chargeCount - 1) forKey:item.billDate];
            if (chargeCount - 1 == 0) {
                [newSectionArr addObject:@(item.chargeIndex.section)];
            }
        }
        [tempDic setObject:originalChargeArr forKey:SSJOrginalChargeArrKey];
        [tempDic setObject:newAddChargeArr forKey:SSJNewAddChargeArrKey];
        [tempDic setObject:newSectionArr forKey:SSJNewAddChargeSectionArrKey];
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
    __block NSString *booksid = SSJGetCurrentBooksType();
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableDictionary *SumDic = [NSMutableDictionary dictionary];
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"SELECT SUM(INCOMEAMOUNT) , SUM(EXPENCEAMOUNT) FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE LIKE '%04ld-%02ld-__' AND CUSERID = '%@' AND CBILLDATE <= '%@' AND CBOOKSID = '%@'", year,month,userid,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"],booksid]];
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
    item.billDate = [set stringForColumn:@"CBILLDATE"];
    return item;
}

+ (NSString *)queryBillNameForBillIds:(NSArray *)billIds {
    __block NSString *billName = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *tmpBillIds = [NSMutableArray arrayWithCapacity:billIds.count];
        for (NSString *billId in billIds) {
            [tmpBillIds addObject:[NSString stringWithFormat:@"'%@'", billId]];
        }
        
        NSString *sql = [NSString stringWithFormat:@"select cname from bk_bill_type where id in (%@)", [tmpBillIds componentsJoinedByString:@","]];
        FMResultSet *resultSet = [db executeQuery:sql];
        
        NSMutableArray *tmpBillNames = [NSMutableArray arrayWithCapacity:billIds.count];
        while ([resultSet next]) {
            NSString *name = [resultSet stringForColumn:@"cname"];
            [tmpBillNames addObject:name];
        }
        [resultSet close];
        
        billName = [tmpBillNames componentsJoinedByString:@"、"];
    }];
    return billName;
}

@end
