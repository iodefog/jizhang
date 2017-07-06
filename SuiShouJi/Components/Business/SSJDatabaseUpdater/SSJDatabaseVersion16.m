//
//  SSJDatabaseVersion16.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion16.h"
#import "SSJDatabaseQueue.h"
#import "SSJReminderItem.h"
#import "SSJUserDefualtRemindCreater.h"

@implementation SSJDatabaseVersion16

+ (NSString *)dbVersion {
    return @"2.6.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self updateFundInfoTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserCrediteTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserRemindTableWithDatabase:db];
    if (error) {
        return error;
    }

    return nil;
}

+ (NSError *)updateFundInfoTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table BK_FUND_INFO add itype integer"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into BK_FUND_INFO (CFUNDID, CACCTNAME, CICOIN, CPARENT, CWRITEDATE, OPERATORTYPE) values ('16','蚂蚁花呗','ft_mayihuabei','root','-1','0')"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set ITYPE = ? where CFUNDID in ('3','11','16')", @(SSJAccountTypeliabilities)]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set ITYPE = ? where CFUNDID not in ('3','11','16')", @(SSJAccountTypeassets)]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@1,@"1"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@2,@"2"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@13,@"3"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@5,@"4"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@6,@"5"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@7,@"6"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@8,@"7"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@9,@"8"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@11,@"10"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@15,@"11"]) {
        return [db lastError];
    }
    
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@10,@"12"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@4,@"13"]) {
        return [db lastError];
    }
    

    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@3,@"14"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@12,@"15"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set IORDER = ? where CFUNDID = ?",@14,@"16"]) {
        return [db lastError];
    }
    


    
    return nil;
}

+ (NSError *)updateUserCrediteTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table BK_USER_CREDIT add ITYPE integer"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_USER_CREDIT set ITYPE = ? where ITYPE is null", @(SSJCrediteCardTypeCrediteCard)]) {
        return [db lastError];
    }
    
    return nil;
}

// 更新user表
+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table BK_USER add CCURRENTSELECTFUNDID text default 'all'"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"alter table BK_USER add CLASTSYNCTIME TEXT"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_USER set ccurrentselectfundid = 'all' where CCURRENTSELECTFUNDID is null"]) {
        return [db lastError];
    }
    
    return nil;
}

// 更新user_remind表
+ (NSError *)updateUserRemindTableWithDatabase:(FMDatabase *)db {
    
    if (![db executeUpdate:@"delete from BK_USER_REMIND where ITYPE = ?",@(SSJReminderTypeCharge)]) {
        return [db lastError];
    }
    
    NSMutableArray *userArr = [NSMutableArray arrayWithCapacity:0];
    
    FMResultSet *result = [db executeQuery:@"select * from BK_USER"];
    
    if (!result) {
        return [db lastError];
    }
    
    while ([result next]) {
        NSString *userid = [result stringForColumn:@"cuserid"];
        [userArr addObject:userid];
    }
    
    NSError *error;
    
    for (NSString *userid in userArr) {
        [SSJUserDefualtRemindCreater createDefaultDataTypeForUserId:userid inDatabase:db error:&error];
    }
    
    if (error) {
        return error;

    }
    
    return nil;
}

@end
