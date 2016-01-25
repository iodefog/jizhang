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
    NSError *error = [self verifyCurrentUserId];
    if (error) {
        failure(error);
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) select ?, 0, ? where not exists (select count(*) from BK_SYNC where CUSERID = ?)", @(SSJDefaultSyncVersion), SSJUSERID(), SSJUSERID()]) {
            SSJUpdateSyncVersion(SSJDefaultSyncVersion + 1);
            success();
            return;
        }
        
        failure([db lastError]);
    }];
}

+ (void)asyncCreateDefaultSyncRecordWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        [self createDefaultSyncRecordWithSuccess:success failure:failure];
    }];
}

+ (void)createDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    NSError *error = [self verifyCurrentUserId];
    if (error) {
        failure(error);
        return;
    }
    
    //  创建默认的资金帐户
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        //  查询用户表中存储的默认资金帐户创建状态
        FMResultSet *reuslt = [db executeQuery:@"select CDEFAULTFUNDACCTSTATE from BK_USER where CUSERID = ?", SSJUSERID()];
        if (!reuslt) {
            failure([db lastError]);
            return;
        }
        
        NSError *error = nil;
        if (![reuslt nextWithError:&error]) {
            [reuslt close];
            failure(error);
            return;
//            if (error) {
//                
//            } else {
//                //  用户表中没有创建该用户的记录
//                
//            }
        }
        
        //  根据表中存储的状态判断是否需要创建以下默认资金帐户
        BOOL defaultFundAcctState = [reuslt boolForColumn:@"CDEFAULTFUNDACCTSTATE"];
        [reuslt close];
        
        if (defaultFundAcctState) {
            success();
            return;
        }
        
        if (![db executeUpdate:@"update BK_USER set CDEFAULTFUNDACCTSTATE = 1"]) {
            failure([db lastError]);
            return;
        }
        
        NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:nil];
        
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '现金账户', '1', '#fe8a65', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '1'", SSJUUID(), writeDate, @(SSJSyncVersion()), SSJUSERID()];
        
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR , CWRITEDATE , OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '储蓄卡余额', '2', '#ffb944', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '2'", SSJUUID(), writeDate, @(SSJSyncVersion()), SSJUSERID()];
        
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '信用卡透支', '3', '#8dc4fa', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '3'", SSJUUID(), writeDate, @(SSJSyncVersion()), SSJUSERID()];
        
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '支付宝余额', '7', '#ffb944', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '7'", SSJUUID() , writeDate, @(SSJSyncVersion()), SSJUSERID()];
        
        [db executeUpdate:@"INSERT INTO BK_FUNS_ACCT (CFUNDID , CUSERID , IBALANCE) SELECT CFUNDID , ? , ? FROM BK_FUND_INFO WHERE CPARENT <> 'root'",SSJUSERID(),[NSNumber numberWithDouble:0.00]];
        
        success();
    }];
}

+ (void)asyncCreateDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        [self createDefaultFundAccountsWithSuccess:success failure:failure];
    }];
}

+ (void)createDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    NSError *error = [self verifyCurrentUserId];
    if (error) {
        failure(error);
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
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
            
            BOOL executeSuccessfull = [db executeUpdate:@"insert into BK_USER_BILL (CUSERID, CBILLID, ISTATE, CWRITEDATE, IVERSION, OPERATORTYPE) select ?, ?, ?, ?, ?, 0 where not exists (select * from BK_USER_BILL where CBILLID = ?)", SSJUSERID(), billId, @(state), date, @(SSJSyncVersion()), billId];
            successfull = successfull && executeSuccessfull;
        }
        
        [billTypeResult close];
        
        if (successfull) {
            success();
        } else {
            failure([db lastError]);
        }
    }];
}

+ (void)asyncCreateDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        [self createDefaultBillTypesIfNeededWithSuccess:success failure:failure];
    }];
}

+ (void)asyncCreateAllDefaultDataWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createDefaultSyncRecordWithSuccess:^{
            [self createDefaultFundAccountsWithSuccess:^{
                [self createDefaultBillTypesIfNeededWithSuccess:success failure:failure];
            } failure:failure];
        } failure:failure];
    });
}

+ (NSError *)verifyCurrentUserId {
    if (SSJUSERID().length) {
        return nil;
    }
    
    return [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"current user id is invalid"}];
}

@end
