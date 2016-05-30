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
#import "SSJDatabaseVersion2.h"
#import "SSJDatabaseVersion3.h"
#import "SSJDatabaseVersion4.h"

// 数据库最新的版本
static const int kDatabaseVersion = 4;

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
    
    // 查询当前数据库的版本
    int currentVersion = [db intForQuery:@"select max(version) from bk_db_version"];
    
    // 升级成功的版本
    int upgradeVersion = currentVersion;
    
    NSError *error = nil;
    
    for (int ver = currentVersion + 1; ver <= kDatabaseVersion; ver ++) {
        Class dbVersionClass = [[self databaseVersionInfo] objectForKey:@(ver)];
        if ([dbVersionClass conformsToProtocol:@protocol(SSJDatabaseVersionProtocol)]) {
            error = [dbVersionClass startUpgradeInDatabase:db];
            if (error) {
                break;
            }
            
            upgradeVersion = ver;
        }
    }
    
    if (upgradeVersion > currentVersion) {
        [db executeUpdate:@"insert into bk_db_version (version) values (?)", @(upgradeVersion)];
    }
    
    return error;
}


+ (NSDictionary *)databaseVersionInfo {
    return @{@1:[SSJDatabaseVersion1 class],
             @2:[SSJDatabaseVersion2 class],
             @3:[SSJDatabaseVersion3 class],
             @4:[SSJDatabaseVersion4 class]};
}

@end
