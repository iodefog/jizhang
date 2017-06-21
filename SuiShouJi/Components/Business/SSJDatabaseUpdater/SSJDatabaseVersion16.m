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
    
    return nil;
}

+ (NSError *)updateFundInfoTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_fund_info add itype integer"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update set itype = ? where cfundid in ('','','')",SSJAccountTypeliabilities]) {
        return [db lastError];
    }
    
    return nil;
}

@end
