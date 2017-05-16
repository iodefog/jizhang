//
//  SSJDatabaseVersion14.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion14.h"
#import "SSJDatabaseQueue.h"

@implementation SSJDatabaseVersion14

+ (NSString *)dbVersion {
    return @"2.3.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    
    NSError *error = [self updateFundInfoTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)updateFundInfoTableWithDatabase:(FMDatabase *)db {
    
    if (![db intForQuery:@"select count(1) from bk_fund_info where cfundid = '15' and cparent = 'root'"]) {
        if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype) values ('15', '其他', 'ft_others', 'root', '-1', 0)"]) {
            return [db lastError];
        }
    }
    
    return nil;
}


@end
