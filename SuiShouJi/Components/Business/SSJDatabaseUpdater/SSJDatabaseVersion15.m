//
//  SSJDatabaseVersion15.m
//  SuiShouJi
//
//  Created by old lang on 17/5/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion15.h"
#import "SSJDatabaseQueue.h"

@implementation SSJDatabaseVersion15

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self createShareBooksTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createShareBooksMemberTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createShareBooksFriendsMarkTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

// 创建预算表
+ (NSError *)createShareBooksTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_SHARE_BOOKS (CBOOKSID TEXT, CCREATOR	TEXT, CADMIN	TEXT, CBOOKSNAME TEXT, CBOOKSCOLOR TEXT, IPARENTTYPE INTEGER, CADDDATE TEXT, IVERSION INTEGER, CWRITEDATE TEXT, OPERATORTYPE INTEGER, PRIMARY KEY(CBOOKSID))"]) {
        return [db lastError];
    }
    return nil;
}

// 创建预算表
+ (NSError *)createShareBooksMemberTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE BK_SHARE_BOOKS_MEMBER (CMEMBERID TEXT, CBOOKSID TEXT, CJOINDATE TEXT, ISTATE INTEGER, PRIMARY KEY(CMEMBERID, CBOOKSID))"]) {
        return [db lastError];
    }
    return nil;
}

// 创建预算表
+ (NSError *)createShareBooksFriendsMarkTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_SHARE_BOOKS_FRIENDS_MARK (CUSERID TEXT, CBOOKSID TEXT, CFRIENDID TEXT, CMARK TEXT, IVERSION INTEGER, CWRITEDATE TEXT, OPERATORTYPE INTEGER, PRIMARY KEY(CUSERID, CBOOKSID, CFRIENDID))"]) {
        return [db lastError];
    }
    return nil;
}

@end
