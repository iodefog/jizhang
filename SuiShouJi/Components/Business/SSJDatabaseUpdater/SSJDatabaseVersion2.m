//
//  SSJDatabaseVersion2.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion2.h"
#import <FMDB/FMDB.h>

@implementation SSJDatabaseVersion2

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = nil;
    error = [self upgradeUserTableWithDatabase:db];
    error = [self createUserTreeWithDatabase:db];
    return error;
}

//  更新用户表
+ (NSError *)upgradeUserTableWithDatabase:(FMDatabase *)db {
    NSError *error = nil;
    if (![db columnExists:@"usersignature" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add usersignature text"]) {
            error = [db lastError];
        }
    }
    if (![db columnExists:@"cwritedate" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add cwritedate text"]) {
            error = [db lastError];
        }
    }
    
    return error;
}

+ (NSError *)createUserTreeWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_user_tree (cuserid text not null, isignin integer not null, isignindate text not null, hasshaked integer default 0, treeimgurl text, treegifurl text)"]) {
        return [db lastError];
    }
    return nil;
}

@end
