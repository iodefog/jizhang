//
//  SSJDatabaseVersion6.m
//  SuiShouJi
//
//  Created by old lang on 16/7/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion6.h"

@implementation SSJDatabaseVersion6

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
    if (![db executeUpdate:@"create table if not exists (cmemberid text not null, cname text not null, cuserid text, cwritedate text, operatortype integer, iversion integer, ccolor text , istate integer , primary key(cmemberid, cuserid))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)createMemberChargeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists (ichargeid text not null, cmemberid text not null, imoney text, cwritedate text, operatortype integer, iversion integer , primary key(cmemberid, cuserid))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_user add cdefaultmembertate integer default 0"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateChargePeriodTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_charge_period_config add CMEMBERIDS text"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)supplementMemberChargeRecordsInDatabase:(FMDatabase *)db {
    [db beginTransaction];
    
    BOOL success = [db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) select ichargeid, '0', imoney, ?, ?, 0 from bk_user_charge", @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]];
    if (!success) {
        [db rollback];
        return [db lastError];
    }
    
    [db commit];
    
    return nil;
}

+ (NSError *)updateUserBudgetWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_user_budget add islastday integer default 0"]) {
        return [db lastError];
    }
    return nil;
}

@end
