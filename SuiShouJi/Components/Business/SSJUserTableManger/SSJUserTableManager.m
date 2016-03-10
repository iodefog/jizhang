//
//  SSJUserTableManager.m
//  SuiShouJi
//
//  Created by old lang on 16/1/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserTableManager.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserTableManager

+ (void)reloadUserIdWithError:(NSError **)error {
    __block NSError *tError = nil;
    
    if (SSJUSERID().length) {
        tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"current userid is invalid"}];
        SSJPRINT(@">>> SSJ warning:current userid is invalid");
        if (error) {
            *error = tError;
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {

        NSString *tUserId = [self unregisteredUserIdInDatabase:db error:&tError];
        
        if (tError) {
            if (error) {
                *error = tError;
            }
            return;
        }
        
        if (tUserId.length) {
            SSJSetUserId(tUserId);
            return;
        }
        
        tUserId = SSJUUID();
        if (![db executeUpdate:@"insert into BK_USER (CUSERID, CREGISTERSTATE, CDEFAULTFUNDACCTSTATE) values (?, 0, 0)", tUserId]) {
            tError = [db lastError];
            if (error) {
                *error = tError;
            }
            return;
        }
        
        SSJSetUserId(tUserId);
    }];
}

+ (NSString *)unregisteredUserIdInDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet *result = [db executeQuery:@"select CUSERID from BK_USER where CREGISTERSTATE = 0"];
    if (!result) {
        *error = [db lastError];
        return nil;
    }
    
    if (![result nextWithError:error]) {
        [result close];
        return nil;
    }
    
    NSString *userId = [result stringForColumnIndex:0];
    [result close];
    
    return userId;
}

+ (void)registerUserIdWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    if (!SSJUSERID().length) {
        SSJPRINT(@">>>SSJ warning:invalid user id");
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"update BK_USER set CREGISTERSTATE = 1 where CUSERID = ?", SSJUSERID()]) {
            if (success) {
                success();
            }
            return;
        }
        
        if (failure) {
            failure([db lastError]);
        }
    }];
}

+ (BOOL)saveUserItem:(SSJUserItem *)userItem {
    NSString *userId = userItem.userId;
    if (!userId || !userId.length) {
        SSJPRINT(@"SSJ Warning:userid不能为空!!!");
        return NO;
    }
    
    NSDictionary *userInfo = [self fieldMapWithUserItem:userItem];
    
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *statment = nil;
        if (![db boolForQuery:@"select count(*) from BK_USER where CUSERID = ?", userId]) {
            statment = [self inertSQLStatementWithUserInfo:userInfo];
        } else {
            statment = [self updateSQLStatementWithUserInfo:userInfo];
        }
        
        success = [db executeUpdate:statment withParameterDictionary:userInfo];
    }];
    
    return success;
}

+ (NSDictionary *)fieldMapWithUserItem:(SSJUserItem *)userItem {
    [SSJUserItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"userId":@"cuserid",
                 @"loginPWD":@"cpwd",
                 @"fundPWD":@"cfpwd",
                 @"motionPWD":@"cmotionpwd",
                 @"motionPWDState":@"cmotionpwdstate",
                 @"nickName":@"cnickid",
                 @"mobileNo":@"cmobileno",
                 @"realName":@"crealname",
                 @"idCardNo":@"cidcard",
                 @"registerState":@"cregisterstate",
                 @"defaultFundAcctState":@"cdefaultfundacctstate",
                 @"icon":@"cicons"};
    }];
    return userItem.mj_keyValues;
}

+ (NSString *)inertSQLStatementWithUserInfo:(NSDictionary *)userInfo {
    NSArray *keys = [userInfo allKeys];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString *key in keys) {
        [values addObject:[NSString stringWithFormat:@":%@", key]];
    }
    
    return [NSString stringWithFormat:@"insert into BK_USER (%@) values (%@)", [keys componentsJoinedByString:@","], [values componentsJoinedByString:@","]];
}

+ (NSString *)updateSQLStatementWithUserInfo:(NSDictionary *)userInfo {
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:[userInfo count]];
    for (NSString *key in [userInfo allKeys]) {
        [keyValues addObject:[NSString stringWithFormat:@"%@ =:%@", key, key]];
    }
    
    return [NSString stringWithFormat:@"update BK_USER set %@ where cuserid = ?", [keyValues componentsJoinedByString:@", "]];
}

@end
