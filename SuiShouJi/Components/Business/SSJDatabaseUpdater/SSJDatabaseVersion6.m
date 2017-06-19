//
//  SSJDatabaseVersion6.m
//  SuiShouJi
//
//  Created by old lang on 16/7/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion6.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion6

+ (NSString *)dbVersion {
    return @"1.6.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self createMemberTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createMemberChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self supplementMemberChargeRecordsInDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserBudgetWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateChargePeriodTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)createMemberTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_member (cmemberid text not null, cname text not null, cuserid text, cwritedate text, operatortype integer, iversion integer, ccolor text , istate integer, cadddate text , primary key(cmemberid, cuserid))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)createMemberChargeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_member_charge (ichargeid text not null, cmemberid text not null, imoney text, cwritedate text, operatortype integer, iversion integer, primary key(ichargeid, cmemberid))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"cdefaultmembertate" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add cdefaultmembertate integer default 0"]) {
            return [db lastError];
        }
    }
    
    if (![db columnExists:@"copenid" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add copenid text"]) {
            return [db lastError];
        }
    }
    
    if (![db columnExists:@"remindsettingmotionpwd" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add remindsettingmotionpwd integer"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)updateChargePeriodTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"CMEMBERIDS" inTableWithName:@"bk_charge_period_config"]) {
        if (![db executeUpdate:@"alter table bk_charge_period_config add CMEMBERIDS text"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)supplementMemberChargeRecordsInDatabase:(FMDatabase *)db {
    
    FMResultSet *result = [db executeQuery:@"select ichargeid, imoney, cuserid from bk_user_charge where operatortype <> 2"];
    if (!result) {
        return [db lastError];
    }
    
    NSMutableArray *memberChargeList = [NSMutableArray array];
    
    while ([result next]) {
        NSString *chargeID = [result stringForColumn:@"ichargeid"];
        NSString *money = [result stringForColumn:@"imoney"];
        NSString *userID = [result stringForColumn:@"cuserid"];
        [memberChargeList addObject:@{@"ichargeid":chargeID,
                                      @"imoney":money,
                                      @"cmemberid":[NSString stringWithFormat:@"%@-0", userID]}];
    }
    
    for (NSDictionary *memberChargeInfo in memberChargeList) {
        NSString *chargeID = memberChargeInfo[@"ichargeid"];
        NSString *memberID = memberChargeInfo[@"cmemberid"];
        NSString *money = memberChargeInfo[@"imoney"];
        
        BOOL success = [db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", chargeID, memberID, money, @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @0];
        if (!success) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)updateUserBudgetWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"islastday" inTableWithName:@"bk_user_budget"]) {
        if (![db executeUpdate:@"alter table bk_user_budget add islastday integer default 0"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

@end
