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
    
    return nil;
}

+ (NSError *)updateFundInfoTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_fund_info add itype integer"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype) values ('16','蚂蚁花呗','ft_huabei','root','-1','0')"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_fund_info set itype = ? where cfundid in ('3','11','16')", @(SSJAccountTypeliabilities)]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_fund_info set itype = ? where cfundid not in ('3','11','16')", @(SSJAccountTypeassets)]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)updateUserCrediteTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_user_credit add itype integer"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_credit set itype = ? where itype is null", @(SSJCrediteCardTypeCrediteCard)]) {
        return [db lastError];
    }
    
    return nil;
}


@end
