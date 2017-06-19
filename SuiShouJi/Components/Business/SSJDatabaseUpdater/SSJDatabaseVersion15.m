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

+ (NSString *)dbVersion {
    return @"2.5.0";
}

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
    
    error = [self updateBillTypeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    
    return nil;
}

// 创建共享账本表
+ (NSError *)createShareBooksTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_SHARE_BOOKS (CBOOKSID TEXT, CCREATOR	TEXT, CADMIN	TEXT, CBOOKSNAME TEXT, CBOOKSCOLOR TEXT, IPARENTTYPE INTEGER, CADDDATE TEXT, IORDER INTEGER, IVERSION INTEGER, CWRITEDATE TEXT, OPERATORTYPE INTEGER, PRIMARY KEY(CBOOKSID))"]) {
        return [db lastError];
    }
    return nil;
}

// 创建共享账本成员表
+ (NSError *)createShareBooksMemberTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_SHARE_BOOKS_MEMBER (CMEMBERID TEXT, CBOOKSID TEXT, CJOINDATE TEXT, ISTATE INTEGER, CCOLOR TEXT, CLEAVEDATE TEXT,CICON TEXT, PRIMARY KEY(CMEMBERID, CBOOKSID))"]) {
        return [db lastError];
    }
    return nil;
}

// 创建共享账本好友备注表
+ (NSError *)createShareBooksFriendsMarkTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_SHARE_BOOKS_FRIENDS_MARK (CUSERID TEXT, CBOOKSID TEXT, CFRIENDID TEXT, CMARK TEXT, IVERSION INTEGER, CWRITEDATE TEXT, OPERATORTYPE INTEGER, PRIMARY KEY(CUSERID, CBOOKSID, CFRIENDID))"]) {
        return [db lastError];
    }
    return nil;
}

// 加入共享账本平账支出平账收入
+ (NSError *)updateBillTypeTableWithDatabase:(FMDatabase *)db {

    if (![db executeUpdate:@"INSERT INTO BK_BILL_TYPE (ID,CNAME,ITYPE,CCOIN,CCOLOR,ISTATE,ICUSTOM) VALUES ('13','平帐收入(共享账本)  ',0,'bt_sharebookpzsr','#9382ad',2,0)"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"INSERT INTO BK_BILL_TYPE (ID,CNAME,ITYPE,CCOIN,CCOLOR,ISTATE,ICUSTOM) VALUES ('14','平帐支出(共享账本)',1,'bt_sharebookpzzc','#5889c5',2,0)"]) {
        return [db lastError];
    }

    return nil;
}


@end
