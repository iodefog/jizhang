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

+ (void)reloadUserIdWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    if (SSJUSERID().length) {
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {

        NSError *error = nil;
        NSString *tUserId = [self unregisteredUserIdInDatabase:db error:&error];
        
        if (error) {
            failure(error);
            return;
        }
        
        if (tUserId.length) {
            SSJSetUserId(tUserId);
            success();
            return;
        }
        
        tUserId = SSJUUID();
        if (![db executeUpdate:@"insert into BK_USER (CUSERID, CREGISTERSTATE, CDEFAULTFUNDACCTSTATE) values (?, 0, 0)", tUserId]) {
            failure([db lastError]);
            return;
        }
        
        SSJSetUserId(tUserId);
        success();
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

@end
