//
//  SSJDatabaseVersion17.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion17.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion17
+ (NSString *)dbVersion {
    return @"2.7.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = nil;
    error = [self createWishTableWithDatabase:db];
    error = [self createWishChargeTableWithDatabase:db];
    return error;
}

+ (NSError *)createWishTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_WISH(WISHID text not null, CUSERID text not null, WISHNAME text not null, WISHMONEY real not null, WISHIMAGE text, IVERSION integer, CWRITEDATE text, OPERATORTYPE integer, ISFINISHED integer, REMINDID text not null, STARTDATE text, ENDDATE text, WISHTYPE integer,primary key(WISHID))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)createWishChargeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_WISH_CHARGE(CHARGEID text not null, MONEY real not null, WISHID text not null, CUSERID text not null, IVERSION integer, CWRITEDATE text, OPERATORTYPE integer, MEMO text, ITYPE integer, CBILLDATE text, primary key(CHARGEID))"]) {
        return db.lastError;
    }
    return nil;
}
@end
