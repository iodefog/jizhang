//
//  SSJFinancingHomeHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/3/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJCreditCardStore.h"
#import "SSJCreditCardItem.h"

@implementation SSJFinancingHomeHelper
+ (void)queryForFundingListWithSuccess:(void(^)(NSArray<SSJFinancingHomeitem *> *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *fundingList = [[NSMutableArray alloc]init];
        NSMutableArray *orderArr = [[NSMutableArray alloc]init];
        FMResultSet * fundingResult = [db executeQuery:@"select a.* , b.ibalance from bk_fund_info  a , bk_funs_acct b where a.cparent != 'root' and a.cfundid = b.cfundid and a.operatortype <> 2 and a.cuserid = ? order by a.iorder asc, a.cparent asc , a.cwritedate desc",userid];
        if (!fundingResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([fundingResult next]) {
            SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
            item.fundingColor = [fundingResult stringForColumn:@"CCOLOR"];
            item.fundingIcon = [fundingResult stringForColumn:@"CICOIN"];
            item.fundingID = [fundingResult stringForColumn:@"CFUNDID"];
            item.fundingName = [fundingResult stringForColumn:@"CACCTNAME"];
            item.fundingParent = [fundingResult stringForColumn:@"CPARENT"];
            item.fundingAmount = [fundingResult doubleForColumn:@"IBALANCE"];
            item.fundingMemo = [fundingResult stringForColumn:@"CMEMO"];
            item.fundingOrder = [fundingResult intForColumn:@"IORDER"];
            [orderArr addObject:@(item.fundingOrder)];
            if ([fundingResult boolForColumn:@"idisplay"] || (![item.fundingParent isEqualToString:@"11"] && ![item.fundingParent isEqualToString:@"10"])) {
                [fundingList addObject:item];
            }
        }
        if ([orderArr containsObject:@(0)]) {
            for (int i = 0; i < fundingList.count; i ++) {
                SSJFinancingHomeitem *item = [fundingList ssj_safeObjectAtIndex:i];
                item.fundingOrder = i + 1;
            }
        }
        [fundingResult close];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(fundingList);
            });
        }
    }];
}

+ (void)queryForFundingSumMoney:(void(^)(double result))success failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        double fundingSum = 0;
        FMResultSet *result = [db executeQuery:@"SELECT SUM(A.IBALANCE) FROM BK_FUNS_ACCT A , BK_FUND_INFO B WHERE A.CFUNDID = B.CFUNDID AND A.CUSERID = ? AND B.OPERATORTYPE <> 2",userid];
        if (!result) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([result next]) {
            fundingSum = [result doubleForColumn:@"SUM(A.IBALANCE)"];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(fundingSum);
            });
        }
    }];
}

+ (SSJFinancingHomeitem *)fundingItemWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
    item.fundingColor = [set stringForColumn:@"CCOLOR"];
    item.fundingIcon = [set stringForColumn:@"CICOIN"];
    item.fundingID = [set stringForColumn:@"CFUNDID"];
    item.fundingName = [set stringForColumn:@"CACCTNAME"];
    item.fundingParent = [set stringForColumn:@"CPARENT"];
    item.fundingAmount = [set doubleForColumn:@"IBALANCE"];
    item.fundingMemo = [set stringForColumn:@"CMEMO"];
    item.fundingOrder = [set intForColumn:@"IORDER"];
    return item;
}


+ (void)SaveFundingOderWithItems:(NSArray <SSJFinancingHomeitem *> *)items error:(NSError **)error{
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i = 0; i < items.count; i++) {
            NSString *sql;
            SSJBaseItem *item = [items ssj_safeObjectAtIndex:i];
            if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
                SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)item;
                fundingItem.fundingOrder = i + 1;
                sql = [NSString stringWithFormat:@"update bk_fund_info set iorder = %ld , cwritedate = '%@' , iversion = %@ , operatortype = 1 where cfundid = '%@'",fundingItem.fundingOrder,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),fundingItem.fundingID];
            }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                cardItem.cardOder = i + 1;
                sql = [NSString stringWithFormat:@"update bk_fund_info set iorder = %ld , cwritedate = '%@' , iversion = %@ , operatortype = 1 where cfundid = '%@'",cardItem.cardOder,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),cardItem.cardId];
            }
            [db executeUpdate:sql];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    }];
}

+ (BOOL)deleteFundingWithFundingItem:(SSJFinancingHomeitem *)item{
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        if ([item.fundingParent isEqualToString:@"10"] || [item.fundingParent isEqualToString:@"11"]) {
            if (![db executeUpdate:@"update bk_fund_info set idisplay = 0 , cwritedate = ? , iversion = ? where cfundid = ?",[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.fundingID]) {
                success = NO;
                return;
            };
        }else{
            if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?",[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.fundingID]) {
                NSLog(@"%@",[db lastError].description);
                success = NO;
                return;
            };
        }
        success = YES;
    }];
    return success;
}

+ (SSJFinancingHomeitem *)queryFundItemWithFundingId:(NSString *)fundingId{
    __block SSJFinancingHomeitem *fundItem = [[SSJFinancingHomeitem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *result = [db executeQuery:@"select a.* , b.ibalance from bk_fund_info  a , bk_funs_acct b where a.cparent != 'root' and a.cfundid = b.cfundid and a.operatortype <> 2 and a.cuserid = ? and a.cfundid = ?",userid,fundingId];
        while ([result next]) {
            fundItem = [self fundingItemWithResultSet:result inDatabase:db];
        }
    }];
    return fundItem;
}

@end
