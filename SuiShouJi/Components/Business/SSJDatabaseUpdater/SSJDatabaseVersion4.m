//
//  SSJDatabaseVersion4.m
//  SuiShouJi
//
//  Created by old lang on 16/5/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion4.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion4

+ (NSString *)dbVersion {
    return @"unknown";
}

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
    
//    FMResultSet *resultSet = [db executeQuery:@"select cuserid from bk_user"];
//    if (!resultSet) {
//        return [db lastError];
//    }
//    
//    NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//    
//    while ([resultSet next]) {
//        NSString *userId = [resultSet stringForColumnIndex:0];
//        
//        [db executeUpdate:@"INSERT INTO BK_BOOKS_TYPE (CBOOKSID, CBOOKSNAME, CBOOKSCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID , IORDER, CICOIN) VALUES (?, ?, ?, ?, 0, ?, ? , ? , ?)",userId, @"日常账本", @"#FC73AE,#FB91BC", writeDate, @(SSJSyncVersion()), userId,@(1),@"bk_moren"];
//        [db executeUpdate:@"INSERT INTO BK_BOOKS_TYPE (CBOOKSID, CBOOKSNAME, CBOOKSCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID , IORDER, CICOIN) VALUES (?, ?, ?, ?, 0, ?, ? , ? , ?)", [NSString stringWithFormat:@"%@-1",userId], @"生意账本", @"#f5a237", writeDate, @(SSJSyncVersion()), userId,@(2),@"bk_shengyi"];
//        [db executeUpdate:@"INSERT INTO BK_BOOKS_TYPE (CBOOKSID, CBOOKSNAME, CBOOKSCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID , IORDER, CICOIN) VALUES (?, ?, ?, ?, 0, ?, ? , ? , ?)", [NSString stringWithFormat:@"%@-2",userId], @"结婚账本", @"#ff6363", writeDate, @(SSJSyncVersion()), userId,@(3),@"bk_jiehun"];
//        [db executeUpdate:@"INSERT INTO BK_BOOKS_TYPE (CBOOKSID, CBOOKSNAME, CBOOKSCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID , IORDER ,CICOIN) VALUES (?, ?, ?, ?, 0, ?, ? , ? , ?)", [NSString stringWithFormat:@"%@-3",userId], @"装修账本", @"#5ca0d9", writeDate, @(SSJSyncVersion()), userId,@(4),@"bk_zhuangxiu"];
//        [db executeUpdate:@"INSERT INTO BK_BOOKS_TYPE (CBOOKSID, CBOOKSNAME, CBOOKSCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, IORDER, CICOIN) VALUES (?, ?, ?, ?, 0, ?, ? , ? , ?)", [NSString stringWithFormat:@"%@-4",userId], @"旅行账本", @"#ad82dd", writeDate, @(SSJSyncVersion()), userId,@(5),@"bk_lvxing"];
//    }
    
    return nil;
}

+ (NSError *)updateUserChargeTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"cbooksid" inTableWithName:@"bk_user_charge"]) {
        if (![db executeUpdate:@"alter table bk_user_charge add cbooksid text"]) {
            return [db lastError];
        }
    }
    
    if (![db executeUpdate:@"update bk_user_charge set cbooksid = cuserid"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserBudgetTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"cbooksid" inTableWithName:@"bk_user_budget"]) {
        if (![db executeUpdate:@"alter table bk_user_budget add cbooksid text"]) {
            return [db lastError];
        }
    }
    
    if (![db executeUpdate:@"update bk_user_budget set cbooksid = cuserid"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateChargePeriodConfigTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"cbooksid" inTableWithName:@"bk_charge_period_config"]) {
        if (![db executeUpdate:@"alter table bk_charge_period_config add cbooksid text"]) {
            return [db lastError];
        }
    }
    
    if (![db executeUpdate:@"update bk_charge_period_config set cbooksid = cuserid"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"cdefaultbookstypestate" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add cdefaultbookstypestate integer default 0"]) {
            return [db lastError];
        }
    }
    
    if (![db columnExists:@"ccurrentbooksid" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add ccurrentbooksid text"]) {
            return [db lastError];
        }
    }
    
    if (![db executeUpdate:@"update bk_user set ccurrentbooksid = cuserid"]) {
        return [db lastError];
    }
    return nil;
}

@end
