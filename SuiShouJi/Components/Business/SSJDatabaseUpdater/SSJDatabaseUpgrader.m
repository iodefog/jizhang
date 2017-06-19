//
//  SSJDatabaseUpgrader.m
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseUpgrader.h"
#import "SSJDatabaseQueue.h"
#import "SSJDatabaseErrorHandler.h"
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
#import "SSJDatabaseVersion11.h"
#import "SSJDatabaseVersion12.h"
#import "SSJDatabaseVersion13.h"
#import "SSJDatabaseVersion14.h"
#import "SSJDatabaseVersion15.h"

// 数据库最新的版本
static const int kDatabaseVersion = 15;

@implementation SSJDatabaseUpgrader

+ (NSError *)upgradeDatabase {
    __block NSError *error = nil;
    __block int currentVersion = 0;
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        db.shouldHandleError = NO;
        if (![db executeUpdate:@"create table if not exists bk_db_version (version integer not null default 0)"]) {
            error = [db lastError];
            NSString *desc = [NSString stringWithFormat:@"code:%d  description:%@  sql:%@", (int)error.code, error.localizedDescription, db.sql];
            NSError *tError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey:desc}];
            [SSJDatabaseErrorHandler handleError:tError];
            return;
        }
        
        // 查询当前数据库的版本
        currentVersion = [db intForQuery:@"select max(version) from bk_db_version"];
        
        for (int ver = currentVersion + 1; ver <= kDatabaseVersion; ver ++) {
            Class dbVersionClass = [[self databaseVersionInfo] objectForKey:@(ver)];
            if ([dbVersionClass conformsToProtocol:@protocol(SSJDatabaseVersionProtocol)]) {
                
                [db beginTransaction];
                
                error = [dbVersionClass startUpgradeInDatabase:db];
                if (error) {
                    NSString *desc = [NSString stringWithFormat:@"数据库升级失败  version:%@  code:%d  description:%@  sql:%@", [dbVersionClass dbVersion], (int)error.code, error.localizedDescription, db.sql];
                    NSError *tError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey:desc}];
                    [SSJDatabaseErrorHandler handleError:tError];
                    [db rollback];
                    break;
                }
                
                if (![db executeUpdate:@"insert into bk_db_version (version) values (?)", @(ver)]) {
                    NSString *desc = [NSString stringWithFormat:@"code:%d  description:%@  sql:%@", (int)error.code, error.localizedDescription, db.sql];
                    NSError *tError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey:desc}];
                    [SSJDatabaseErrorHandler handleError:tError];
                    [db rollback];
                    break;
                }
                
                [db commit];
            }
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
             @10:[SSJDatabaseVersion10 class],
             @11:[SSJDatabaseVersion11 class],
             @12:[SSJDatabaseVersion12 class],
             @13:[SSJDatabaseVersion13 class],
             @14:[SSJDatabaseVersion14 class],
             @15:[SSJDatabaseVersion15 class]};
}

@end
