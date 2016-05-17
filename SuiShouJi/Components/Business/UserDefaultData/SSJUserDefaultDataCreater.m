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

+ (void)createDefaultSyncRecordWithError:(NSError **)error {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSError *tError = [self createDefaultSyncRecordInDatabase:db];
        if (error) {
            *error = tError;
        }
    }];
}

+ (void)asyncCreateDefaultSyncRecordWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = [self createDefaultSyncRecordInDatabase:db];
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if (success) {
                success();
            }
        }
    }];
}

+ (void)createDefaultFundAccountsWithError:(NSError **)error {
    //  创建默认的资金帐户
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSError *tError = [self createDefaultFundAccountsForUserId:SSJUSERID() inDatabase:db];
        if (error) {
            *error = tError;
        }
    }];
}

+ (void)asyncCreateDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    //  创建默认的资金帐户
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = [self createDefaultFundAccountsForUserId:SSJUSERID() inDatabase:db];
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if (success) {
                success();
            }
        }
    }];
}

+ (void)createDefaultBillTypesIfNeededWithError:(NSError **)error {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSError *tError = [self createDefaultBillTypesIfNeededForUserId:SSJUSERID() inDatabase:db];
        if (error) {
            *error = tError;
        }
    }];
}

+ (void)asyncCreateDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    NSString *userId = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = [self createDefaultBillTypesIfNeededForUserId:userId inDatabase:db];
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if (success) {
                success();
            }
        }
    }];
}

+ (void)asyncCreateAllDefaultDataWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    NSString *userId = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = [self createDefaultSyncRecordInDatabase:db];
        if (error) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        error = [self createDefaultFundAccountsForUserId:userId inDatabase:db];
        if (error) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        error = [self createDefaultBillTypesIfNeededForUserId:userId inDatabase:db];
        if (error) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        if (success) {
            success();
        }
    }];
}

//  如果同步表中没有当前用户数据，就创建默认同步表数据
+ (NSError *)createDefaultSyncRecordInDatabase:(FMDatabase *)db {
    if (!SSJUSERID().length) {
        return [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"current user id is invalid"}];
    }
    
    if ([db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) select ?, 0, ? where not exists (select count(*) from BK_SYNC where CUSERID = ?)", @(SSJDefaultSyncVersion), SSJUSERID(), SSJUSERID()]) {
        SSJUpdateSyncVersion(SSJDefaultSyncVersion + 1);
        return nil;
    }
    
    return [db lastError];
}

//  如果当前用户没有创建过默认的资金帐户，则创建默认资金帐户
+ (NSError *)createDefaultFundAccountsForUserId:(NSString *)userId inDatabase:(FMDatabase *)db {
    if (!userId.length) {
        return [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"current user id is invalid"}];
    }
    
    //  查询用户表中存储的默认资金帐户创建状态
    FMResultSet *reuslt = [db executeQuery:@"select CDEFAULTFUNDACCTSTATE from BK_USER where CUSERID = ?", userId];
    if (!reuslt) {
        return [db lastError];
    }
    
    NSError *error = nil;
    if (![reuslt nextWithError:&error]) {
        [reuslt close];
        if (error) {
            return error;
        }
        return nil;
    }
    
    //  根据表中存储的状态判断是否需要创建以下默认资金帐户
    BOOL defaultFundAcctState = [reuslt boolForColumn:@"CDEFAULTFUNDACCTSTATE"];
    [reuslt close];
    
    if (defaultFundAcctState) {
        return nil;
    }
    
    if (![db executeUpdate:@"update BK_USER set CDEFAULTFUNDACCTSTATE = 1"]) {
        return [db lastError];
    }
    
    NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '现金', '1', '#fc7a60', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '1'", SSJUUID(), writeDate, @(SSJSyncVersion()), userId];
    [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR , CWRITEDATE , OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '储蓄卡', '2', '#faa94a', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '2'", SSJUUID(), writeDate, @(SSJSyncVersion()), userId];
    [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '信用卡', '3', '#8bb84a', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '3'", SSJUUID(), writeDate, @(SSJSyncVersion()), userId];
    [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '支付宝', '7', '#5a98de', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '7'", SSJUUID() , writeDate, @(SSJSyncVersion()), userId];
    
    //  根据默认的资金帐户创建资金帐户余额
    [db executeUpdate:@"INSERT INTO BK_FUNS_ACCT (CFUNDID , CUSERID , IBALANCE) SELECT CFUNDID , ? , ? FROM BK_FUND_INFO WHERE CPARENT <> 'root' and cuserid = ?", userId, @0.00, userId];
    
    return nil;
}

//  如果当前用户的收支类型小于公共收支类型，则创建缺少的收支类型
+ (NSError *)createDefaultBillTypesIfNeededForUserId:(NSString *)userID inDatabase:(FMDatabase *)db {
    if (!userID.length) {
        return [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"current user id is invalid"}];
    }
    
    FMResultSet *result1 = [db executeQuery:@"select count(*) from BK_BILL_TYPE where istate <> 2"];
    FMResultSet *result2 = [db executeQuery:@"select count(*) from BK_USER_BILL where CUSERID = ?", userID];
    
    if (!result1 || !result2) {
        [result1 close];
        [result2 close];
        return [db lastError];
    }
    
    [result1 next];
    [result2 next];
    
    if ([result1 intForColumnIndex:0] <= [result2 intForColumnIndex:0]) {
        [result1 close];
        [result2 close];
        return nil;
    }
    
    [result1 close];
    [result2 close];
    
    FMResultSet *billTypeResult = [db executeQuery:@"select id, istate, defaultOrder from BK_BILL_TYPE where istate <> 2"];
    if (!billTypeResult) {
        return [db lastError];
    }
    
    BOOL successfull = YES;
    NSString *date = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    while ([billTypeResult next]) {
        NSString *billId = [billTypeResult stringForColumn:@"id"];
        int state = [billTypeResult intForColumn:@"istate"];
        NSString *order = [billTypeResult stringForColumn:@"defaultOrder"];
        
        BOOL executeSuccessfull = [db executeUpdate:@"insert into BK_USER_BILL (CUSERID, CBILLID, ISTATE, IORDER, CWRITEDATE, IVERSION, OPERATORTYPE) select ?, ?, ?, ?, ?, ?, 0 where not exists (select * from BK_USER_BILL where CBILLID = ? and cuserid = ?)", userID, billId, @(state), order, date, @(SSJSyncVersion()), billId, userID];
        successfull = successfull && executeSuccessfull;
    }
    
    [billTypeResult close];
    
    if (successfull) {
        return nil;
    } else {
        return [db lastError];
    }
}

@end
