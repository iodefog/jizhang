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
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
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

+ (void)createDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    //  创建默认的资金帐户
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSError *error = [self createDefaultFundAccountsInDatabase:db];
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

+ (void)asyncCreateDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    //  创建默认的资金帐户
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = [self createDefaultFundAccountsInDatabase:db];
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

+ (void)createDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSError *error = [self createDefaultBillTypesIfNeededInDatabase:db];
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

+ (void)asyncCreateDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = [self createDefaultBillTypesIfNeededInDatabase:db];
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
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = [self createDefaultSyncRecordInDatabase:db];
        if (error) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        error = [self createDefaultFundAccountsInDatabase:db];
        if (error) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        error = [self createDefaultBillTypesIfNeededInDatabase:db];
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
+ (NSError *)createDefaultFundAccountsInDatabase:(FMDatabase *)db {
    if (!SSJUSERID().length) {
        return [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"current user id is invalid"}];
    }
    
    //  查询用户表中存储的默认资金帐户创建状态
    FMResultSet *reuslt = [db executeQuery:@"select CDEFAULTFUNDACCTSTATE from BK_USER where CUSERID = ?", SSJUSERID()];
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
        return nil;
    }
    
    if (![db executeUpdate:@"update BK_USER set CDEFAULTFUNDACCTSTATE = 1"]) {
        return [db lastError];
    }
    
    NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:nil];
    
    [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '现金', '1', '#fe8a65', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '1'", SSJUUID(), writeDate, @(SSJSyncVersion()), SSJUSERID()];
    
    [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR , CWRITEDATE , OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '储蓄卡', '2', '#ffb944', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '2'", SSJUUID(), writeDate, @(SSJSyncVersion()), SSJUSERID()];
    
    [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '信用卡', '3', '#8dc4fa', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '3'", SSJUUID(), writeDate, @(SSJSyncVersion()), SSJUSERID()];
    
    [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN) SELECT ?, '支付宝', '7', '#ffb944', ?, 0, ?, ?, CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '7'", SSJUUID() , writeDate, @(SSJSyncVersion()), SSJUSERID()];
    
    [db executeUpdate:@"INSERT INTO BK_FUNS_ACCT (CFUNDID , CUSERID , IBALANCE) SELECT CFUNDID , ? , ? FROM BK_FUND_INFO WHERE CPARENT <> 'root'",SSJUSERID(),[NSNumber numberWithDouble:0.00]];
    
    return nil;
}

//  如果当前用户的收支类型小于公共收支类型，则创建缺少的收支类型
+ (NSError *)createDefaultBillTypesIfNeededInDatabase:(FMDatabase *)db {
    if (!SSJUSERID().length) {
        return [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"current user id is invalid"}];
    }
    
    FMResultSet *result1 = [db executeQuery:@"select count(*) from BK_BILL_TYPE"];
    FMResultSet *result2 = [db executeQuery:@"select count(*) from BK_USER_BILL where CUSERID = ?", SSJUSERID()];
    
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
    
    FMResultSet *billTypeResult = [db executeQuery:@"select id, istate from BK_BILL_TYPE"];
    if (!billTypeResult) {
        return [db lastError];
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
        return nil;
    } else {
        return [db lastError];
    }
}

@end
