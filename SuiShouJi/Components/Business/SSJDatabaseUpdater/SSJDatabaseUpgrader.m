//
//  SSJDatabaseUpgrader.m
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseUpgrader.h"
#import "SSJDatabaseQueue.h"
#import "SSJDatabaseVersionProtocol.h"
#import "SSJDatabaseVersion1.h"

static const int kDatabaseVersion = 1;

@implementation SSJDatabaseUpgrader

+ (NSError *)upgradeDatabase {
    __block NSError *error = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        error = [self startUpgradeInDatabase:db];
    }];
    return error;
}

+ (void)upgradeDatabaseWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = [self startUpgradeInDatabase:db];
        
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

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_db_version (version integer not null default 0)"]) {
        return [db lastError];
    }
    
    NSError *error = nil;
    
    int version = [db intForQuery:@"select version from bk_db_version"];
    for (int i = version + 1; i <= kDatabaseVersion; i ++) {
        NSError *tError = nil;
        Class dbVersionClass = [[self databaseVersionInfo] objectForKey:@(i)];
        if ([self conformsToProtocol:@protocol(SSJDatabaseVersionProtocol)]) {
            tError = [dbVersionClass startUpgradeInDatabase:db];
            if (tError) {
                error = tError;
            }
        }
    }
    
    return error;
}


+ (NSDictionary *)databaseVersionInfo {
    return @{@1:[SSJDatabaseVersion1 class]};
}

@end
