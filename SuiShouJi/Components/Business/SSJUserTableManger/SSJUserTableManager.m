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

//+ (NSCache *)memCache {
//    static NSCache *cache = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        cache = [[NSCache alloc] init];
//    });
//    return cache;
//}

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

+ (void)saveCurrentUserIdWithError:(NSError **)error {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:@"insert into BK_USER (CUSERID, CREGISTERSTATE, CDEFAULTFUNDACCTSTATE) select ?, 1, 0 where not exists (select count(*) from BK_USER where cuserid = ?)", SSJUSERID(), SSJUSERID()]) {
            if (error) {
                *error = [db lastError];
            }
        }
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

+ (void)asyncSaveMobileNo:(NSString *)mobileNo success:(void (^)(void))success failure:(void (^)(NSError *error))failure; {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"update bk_user set cmobileno = ? where cuserid = ?", mobileNo, SSJUSERID()]) {
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

@end
