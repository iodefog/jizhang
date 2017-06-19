//
//  SSJDatabaseVersion2.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion2.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion2

+ (NSString *)dbVersion {
    return @"unknown";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self upgradeUserTableWithDatabase:db];;
    if (error) {
        return error;
    }
    
    error = [self createUserTreeWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

//  更新用户表
+ (NSError *)upgradeUserTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"usersignature" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add usersignature text"]) {
            return [db lastError];
        }
    }
    if (![db columnExists:@"cwritedate" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add cwritedate text"]) {
            return [db lastError];
        }
        if (![db executeUpdate:@"update bk_user set cwritedate = ?", [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)createUserTreeWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_user_tree (cuserid text not null, isignin integer not null, isignindate text not null, hasshaked integer default 0, treeimgurl text, treegifurl text)"]) {
        return [db lastError];
    }
    return nil;
}

@end
