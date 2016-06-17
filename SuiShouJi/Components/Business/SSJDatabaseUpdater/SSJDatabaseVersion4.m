//
//  SSJDatabaseVersion4.m
//  SuiShouJi
//
//  Created by old lang on 16/5/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion4.h"
#import <FMDB/FMDB.h>

@implementation SSJDatabaseVersion4

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self createBooksTypeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserBudgetTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateDailySumChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateChargePeriodConfigTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)createBooksTypeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_books_type (cbooksid text not null, cbooksname text not null, cbookscolor text, cwritedate text, operatortype integer, iversion integer, cuserid text, iorder integer, cicoin text, primary key(cbooksid, cuserid))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserChargeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_user_charge add cbooksid text"]) {
        return [db lastError];
    }
    if (![db executeUpdate:@"update bk_user_charge set cbooksid = cuserid"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserBudgetTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_user_budget add cbooksid text"]) {
        return [db lastError];
    }
    if (![db executeUpdate:@"update bk_user_budget set cbooksid = cuserid"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateDailySumChargeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_dailysum_charge add cbooksid text"]) {
        return [db lastError];
    }
    if (![db executeUpdate:@"update bk_dailysum_charge set cbooksid = cuserid"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateChargePeriodConfigTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_charge_period_config add cbooksid text"]) {
        return [db lastError];
    }
    if (![db executeUpdate:@"update bk_charge_period_config set cbooksid = cuserid"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_user add cdefaultbookstypestate integer default 0"]) {
        return [db lastError];
    }
    if (![db executeUpdate:@"alter table bk_user add ccurrentbooksid text"]) {
        return [db lastError];
    }
    if (![db executeUpdate:@"update bk_user set ccurrentbooksid = cuserid"]) {
        return [db lastError];
    }
    return nil;
}

@end
