//
//  SSJDatabaseVersion16.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion16.h"
#import "SSJDatabaseQueue.h"

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
    
    return nil;
}

+ (NSError *)updateFundInfoTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_fund_info add itype integer"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into BK_FUND_INFO (CFUNDID, CACCTNAME, CICOIN, CPARENT, CWRITEDATE, OPERATORTYPE) values ('16','蚂蚁花呗','ft_huabei','root','-1','0')"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set ITYPE = ? where CFUNDID in ('3','11','16')", @(SSJAccountTypeliabilities)]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update BK_FUND_INFO set ITYPE = ? where CFUNDID not in ('3','11','16')", @(SSJAccountTypeassets)]) {
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

@end
