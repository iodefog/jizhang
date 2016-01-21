//
//  SSJUserDefaultDataCreater.m
//  SuiShouJi
//
//  Created by old lang on 16/1/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserDefaultDataCreater.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserDefaultDataCreater

+ (void)createDefaultSyncRecordWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values(?, 0, ?)", @(SSJDefaultSyncVersion), SSJUSERID()]) {
            SSJUpdateSyncVersion(SSJDefaultSyncVersion + 1);
            success();
            return;
        }
        
        failure([db lastError]);
    }];
}

+ (void)createDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    //  判断当前userid有没有创建过默认资金帐户
    NSString *key = @"SSJIsFundAccountsCreateKey";
    NSDictionary *userFundAccountInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
    if (userFundAccountInfo[SSJUSERID()]) {
        success();
        return;
    }
    
    //  创建默认的资金帐户
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:nil];
        
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID , CACCTNAME , CPARENT , CCOLOR , CWRITEDATE , OPERATORTYPE , IVERSION , CUSERID, CICOIN) SELECT ?, '现金账户', '1', '#fe8a65', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '1'", SSJUUID(), writeDate , SSJSyncVersion(), SSJUSERID()];
        
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID , CACCTNAME , CPARENT , CCOLOR , CWRITEDATE , OPERATORTYPE , IVERSION , CUSERID, CICOIN) SELECT ?, '储蓄卡余额', '2', '#ffb944', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '2'", SSJUUID(), writeDate, SSJSyncVersion(), SSJUSERID()];
        
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '信用卡透支', '3', '#8dc4fa', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '3'", SSJUUID(), writeDate, SSJSyncVersion(), SSJUSERID()];
        
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '支付宝余额', '7', '#ffb944', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '7'", SSJUUID() , writeDate, SSJSyncVersion(), SSJUSERID()];
        
        [db executeUpdate:@"INSERT INTO BK_FUNS_ACCT (CFUNDID , CUSERID , IBALANCE) SELECT CFUNDID , ? , ? FROM BK_FUND_INFO WHERE CPARENT <> 'root'",SSJUSERID(),[NSNumber numberWithDouble:0.00]];
        
        //  标记当前userid创建过默认资金帐户
        NSMutableDictionary *newUserFundAcctInfo = [userFundAccountInfo mutableCopy];
        [newUserFundAcctInfo setObject:@(YES) forKey:SSJUSERID()];
        [[NSUserDefaults standardUserDefaults] setObject:newUserFundAcctInfo forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        success();
    }];
}

+ (void)createDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result1 = [db executeQuery:@"select count(*) from BK_BILL_TYPE"];
        FMResultSet *result2 = [db executeQuery:@"select count(*) from BK_USER_BILL where CUSERID = ?", SSJUSERID()];
        
        if (!result1 || !result2) {
            failure([db lastError]);
            [result1 close];
            [result2 close];
            return;
        }
        
        [result1 next];
        [result2 next];
        
        if ([result1 intForColumnIndex:0] <= [result2 intForColumnIndex:0]) {
            success();
            [result1 close];
            [result2 close];
            return;
        }
        
        [result1 close];
        [result2 close];
        
        FMResultSet *billTypeResult = [db executeQuery:@"select id, istate from BK_BILL_TYPE"];
        if (!billTypeResult) {
            failure([db lastError]);
            return;
        }
        
        BOOL successfull = YES;
        while ([billTypeResult next]) {
            NSString *billId = [billTypeResult stringForColumn:@"id"];
            int state = [billTypeResult intForColumn:@"istate"];
            NSString *date = [[NSDate date] ssj_systemCurrentDateWithFormat:nil];
            
            BOOL executeSuccessfull = [db executeUpdate:@"insert into BK_USER_BILL (CUSERID, CBILLID, ISTATE, CWRITEDATE, IVERSION, OPERATORTYPE) select ?, ?, ?, ?, ?, 0 where not exists (select * from BK_USER_BILL where CBILLID = ?)", SSJUSERID(), billId, @(state), date, SSJSyncVersion(), billId];
            successfull = successfull && executeSuccessfull;
        }
        
        if (successfull) {
            success();
        } else {
            failure([db lastError]);
        }
    }];
}

+ (void)createAllDefaultDataWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
}

@end
