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
NSString *const SSJMonthSumDicKey = @"SSJMonthSumDicKey";

@implementation SSJBookKeepingHomeHelper

+ (void)queryForChargeListExceptNewCharge:(NSArray *)newCharge
                              Success:(void(^)(NSDictionary *result))success
                             failure:(void (^)(NSError *error))failure
{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *booksid = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", userid];
        if (!booksid.length) {
            booksid = userid;
        }
        NSMutableArray *originalChargeArr = [NSMutableArray array];
        NSMutableArray *newAddChargeArr = [NSMutableArray array];
        NSMutableArray *newSectionArr = [NSMutableArray array];
        NSMutableDictionary *summaryDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        NSString *lastDate = @"";
        NSInteger totalCount = 0;
        
        int section = 0;
        int row = 0;
        FMResultSet *chargeResult = [db executeQuery:@"select uc.* , uc.operatortype as chargeoperatortype, bt.cname, bt.cicoin, bt.ccolor, bt.itype, bf.cmark from bk_user_charge uc left join bk_share_books_friends_mark bf on bf.cfriendid = uc.cuserid and bf.cbooksid = uc.cbooksid and bf.cuserid = ? , bk_user_bill_type bt where uc.ibillid = bt.cbillid and bt.cuserid = uc.cuserid and bt.cbooksid = uc.cbooksid and uc.cbilldate <= ? and uc.cbooksid = ? and uc.operatortype <> 2 order by uc.cbilldate desc , uc.clientadddate desc , uc.cwritedate desc", SSJUSERID(), [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"],booksid];
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
            item.imageName = [chargeResult stringForColumn:@"cicoin"];
            item.typeName = [chargeResult stringForColumn:@"cname"];
            item.money = [chargeResult stringForColumn:@"imoney"];
            item.colorValue = [chargeResult stringForColumn:@"ccolor"];
            item.incomeOrExpence = [chargeResult boolForColumn:@"itype"];
            item.ID = [chargeResult stringForColumn:@"ichargeid"];
            item.userId = [chargeResult stringForColumn:@"cuserid"];
            item.fundId = [chargeResult stringForColumn:@"ifunsid"];
            item.editeDate = [chargeResult stringForColumn:@"cwritedate"];
            item.billId = [chargeResult stringForColumn:@"ibillid"];
            item.chargeImage = [chargeResult stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [chargeResult stringForColumn:@"thumburl"];
            item.chargeMemo = [chargeResult stringForColumn:@"cmemo"];
            item.operatorType = [chargeResult intForColumn:@"CHARGEOPERATORTYPE"];
            item.billDate = [chargeResult stringForColumn:@"cbilldate"];
            item.clientAddDate = [chargeResult stringForColumn:@"clientadddate"];
            item.billDetailDate = [chargeResult stringForColumn:@"cdetaildate"];
            item.memberNickname = [chargeResult stringForColumn:@"cmark"];
            item.idType = [chargeResult intForColumn:@"ichargetype"];
            item.sundryId = [chargeResult stringForColumn:@"cid"];
            
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
                item.chargeIndex = [NSIndexPath indexPathForRow:row inSection:section - 1];
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
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *booksid = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", userid];
        booksid = booksid.length > 0 ? booksid : userid;
        NSMutableDictionary *SumDic = [NSMutableDictionary dictionary];
        
        double incomeSum = [db doubleForQuery:[NSString stringWithFormat:@"select sum(imoney) from bk_user_charge uc, bk_user_bill_type bt where uc.cbooksid = '%@' and uc.cbilldate like '%04ld-%02ld-__' AND uc.cbilldate <= '%@' and uc.ibillid = bt.cbillid and uc.cuserid = bt.cuserid and uc.cbooksid = bt.cbooksid and bt.itype = %d and uc.operatortype <> 2", booksid, year, month,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"], (int)SSJBillTypeIncome]];
        
        double expentureSum = [db doubleForQuery:[NSString stringWithFormat:@"select sum(imoney) from bk_user_charge uc, bk_user_bill_type bt where uc.cbooksid = '%@' and uc.cbilldate like '%04ld-%02ld-__' AND uc.cbilldate <= '%@' and uc.ibillid = bt.cbillid and uc.cuserid = bt.cuserid and uc.cbooksid = bt.cbooksid and bt.itype = %d and uc.operatortype <> 2", booksid, year, month,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"], (int)SSJBillTypePay]];
        
        [SumDic setObject:@(incomeSum) forKey:SSJIncomeSumlKey];
        
        [SumDic setObject:@(expentureSum) forKey:SSJExpentureSumKey];

        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(SumDic);
            });
        }
    }];

}

+ (NSString *)queryBillNameForBillIds:(NSArray *)billIds booksID:(NSString *)booksID userID:(NSString *)userID {
    __block NSString *billName = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *tmpBillIds = [NSMutableArray arrayWithCapacity:billIds.count];
        for (NSString *billId in billIds) {
            [tmpBillIds addObject:[NSString stringWithFormat:@"'%@'", billId]];
        }
        
        NSString *sql = [NSString stringWithFormat:@"select cname from bk_user_bill_type where cbillid in (%@) and cbooksid = ? and cuserid = ?", [tmpBillIds componentsJoinedByString:@","]];
        FMResultSet *resultSet = [db executeQuery:sql, booksID, userID];
        
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
