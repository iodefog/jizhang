//
//  SSJFinancingHomeHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/3/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeHelper.h"
#import "SSJDatabaseQueue.h"

@implementation SSJFinancingHomeHelper

+ (void)queryForFundingListWithSuccess:(void(^)(NSArray<SSJFinancingHomeitem *> *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *fundingList = [[NSMutableArray alloc]init];
        FMResultSet * fundingResult = [db executeQuery:@"SELECT A.* , B.IBALANCE FROM BK_FUND_INFO  A , BK_FUNS_ACCT B WHERE A.CPARENT != 'root' AND A.CFUNDID = B.CFUNDID AND A.OPERATORTYPE <> 2 AND A.CUSERID = ? ORDER BY A.CPARENT ASC , A.CWRITEDATE DESC",userid];
        if (!fundingResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([fundingResult next]) {
            [fundingList addObject:[self fundingItemWithResultSet:fundingResult inDatabase:db]];
        }
        SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc]init];
        item.fundingName = @"添加资金账户";
        item.fundingColor = @"cccccc";
        item.fundingIcon = @"add";
        item.isAddOrNot = YES;
        [fundingList addObject:item];
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
    item.isAddOrNot = NO;
    return item;
}
@end
