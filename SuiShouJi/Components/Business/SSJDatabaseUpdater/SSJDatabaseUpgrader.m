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
#import "SSJDatabaseVersion5.h"
#import "SSJDatabaseVersion6.h"
#import "SSJDatabaseVersion7.h"
#import "SSJDatabaseVersion8.h"
#import "SSJDatabaseVersion9.h"
#import "SSJDatabaseVersion10.h"

// 数据库最新的版本
static const int kDatabaseVersion = 10;

@implementation SSJDatabaseUpgrader

+ (NSError *)upgradeDatabase {
    __block NSError *error = nil;
    __block int currentVersion = 0;
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:@"create table if not exists bk_db_version (version integer not null default 0)"]) {
            error = [db lastError];
            return;
        }
        // 查询当前数据库的版本
        currentVersion = [db intForQuery:@"select max(version) from bk_db_version"];
        
        // 升级成功的版本
        int upgradeVersion = currentVersion;
        
        for (int ver = currentVersion + 1; ver <= kDatabaseVersion; ver ++) {
            Class dbVersionClass = [[self databaseVersionInfo] objectForKey:@(ver)];
            if ([dbVersionClass conformsToProtocol:@protocol(SSJDatabaseVersionProtocol)]) {
                
                [db beginTransaction];
                
                error = [dbVersionClass startUpgradeInDatabase:db];
                if (error) {
                    [db rollback];
                    break;
                }
                
                [db commit];
                upgradeVersion = ver;
            }
        }
        
        if (upgradeVersion > currentVersion) {
            [db executeUpdate:@"insert into bk_db_version (version) values (?)", @(upgradeVersion)];
        }
    }];
    
    return error;
}

+ (NSDictionary *)databaseVersionInfo {
    return @{@1:[SSJDatabaseVersion1 class],
             @2:[SSJDatabaseVersion2 class],
             @3:[SSJDatabaseVersion3 class],
             @4:[SSJDatabaseVersion4 class],
             @5:[SSJDatabaseVersion5 class],
             @6:[SSJDatabaseVersion6 class],
             @7:[SSJDatabaseVersion7 class],
             @8:[SSJDatabaseVersion8 class],
             @9:[SSJDatabaseVersion9 class],
             @9:[SSJDatabaseVersion10 class]};
}

@end
