//
//  SSJDatabaseVersion8.m
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion8.h"

@implementation SSJDatabaseVersion8

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self updateFundInfoTableAndFunsAcctTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createLoanTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createUserCreditTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createUserRemindTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self insertDefaultRemindWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateBillTypeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    // 先前版本有每日提醒，此版本后提醒改变了，所以要取消之前所有提醒
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    return nil;
}

+ (NSError *)updateFundInfoTableAndFunsAcctTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_fund_info add idisplay integer default 1"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_fund_info set cacctname = '借出款', cmemo = '应收钱款' where cfundid = '9'"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype, cmemo) values (?, ?, ?, ?, ?, ?, ?)", @"10", @"借出款", @"ft_jiechukuan", @"root", @"-1", @"0", @"应收钱款"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", @"11", @"欠款", @"ft_qiankuan", @"root", @"-1", @"0"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype, cmemo) values (?, ?, ?, ?, ?, ?, ?)", @"12", @"社保", @"ft_shebao", @"root", @"-1", @"0", @"医保"]) {
        return [db lastError];
    }
    
    FMResultSet *result = [db executeQuery:@"select cuserid from bk_user"];
    if (!result) {
        return [db lastError];
    }
    
    NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    while ([result next]) {
        NSString *userId = [result stringForColumn:@"cuserid"];
        NSString *lendFundID = [NSString stringWithFormat:@"%@-5",userId];
        NSString *borrowFundID = [NSString stringWithFormat:@"%@-6",userId];
        
        int maxOrder = [db intForQuery:@"select max(iorder) from bk_fund_info where cuserid = ?", userId];
        
        if (![db executeUpdate:@"insert into BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN, IORDER) values (?, '借出款', '10', '#a883d8', ?, 0, ?, ?, 'ft_jiechukuan', ?)", lendFundID, writeDate, @(SSJSyncVersion()), userId, @(maxOrder + 1)]) {
            return [db lastError];
        }
        
        if (![db executeUpdate:@"insert into BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN, IORDER) values (?, '欠款', '11', '#ef6161', ?, 0, ?, ?, 'ft_qiankuan', ?)", borrowFundID, writeDate, @(SSJSyncVersion()), userId, @(maxOrder + 2)]) {
            return [db lastError];
        }
        
        if (![db executeUpdate:@"insert into BK_FUNS_ACCT (CFUNDID, CUSERID, IBALANCE) values (?, ?, ?)", lendFundID, userId, @0.00]) {
            return [db lastError];
        }
        
        if (![db executeUpdate:@"insert into BK_FUNS_ACCT (CFUNDID, CUSERID, IBALANCE) values (?, ?, ?)", borrowFundID, userId, @0.00]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)createLoanTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_LOAN (LOANID text not null, CUSERID text, LENDER text, JMONEY numeric, CTHEFUNDID text, CTARGETFUNDID text, CETARGET text, CTHECHARGE text, CTARGETCHARGE text, CETHECHARGE text, CETARGETCHARGE text, CINTERESTID text, CBORROWDATE text, CREPAYMENTDATE text, CENDDATE text, RATE numeric, MEMO text, INTEREST integer, CREMINDID text, CWRITEDATE text, IVERSION integer, OPERATORTYPE integer, IEND integer, ITYPE integer, primary key(LOANID))"]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)createUserCreditTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_USER_CREDIT (CFUNDID TEXT NOT NULL, IQUOTA NUMERIC, CBILLDATE TEXT, CREPAYMENTDATE TEXT, CUSERID TEXT, CWRITEDATE TEXT, IVERSION INTEGER, OPERATORTYPE INTEGER, CREMINDID TEXT, IBILLDATESETTLEMENT INTEGER, PRIMARY KEY(CFUNDID))"]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)createUserRemindTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_USER_REMIND (CREMINDID TEXT NOT NULL, CUSERID TEXT, CREMINDNAME TEXT, CMEMO TEXT, CSTARTDATE TEXT, ISTATE INTEGER, ITYPE INTEGER, ICYCLE INTEGER, IISEND INTEGER, CWRITEDATE TEXT, IVERSION INTEGER, OPERATORTYPE INTEGER, PRIMARY KEY(CREMINDID))"]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)insertDefaultRemindWithDatabase:(FMDatabase *)db {
    BOOL open = NO;
    NSString *time = nil;
    FMResultSet *result = [db executeQuery:@"select * from BK_CHARGE_REMINDER"];
    while ([result next]) {
        open = [result boolForColumn:@"ISONORNOT"];
        time = [result stringForColumn:@"TIME"];
    }
    [result close];
    
    NSDate *remindDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:18 minute:0 second:0];
    NSString *remindDateStr = [remindDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    result = [db executeQuery:@"select CUSERID from BK_USER"];
    while ([result next]) {
        NSString *userID = [result stringForColumn:@"CUSERID"];
        if (![db executeUpdate:@"insert into BK_USER_REMIND (CREMINDID, CUSERID, CREMINDNAME, CMEMO, CSTARTDATE, ISTATE, ITYPE, ICYCLE, IISEND, CWRITEDATE, IVERSION, OPERATORTYPE) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", SSJUUID(), userID, @"记账提醒", @"", remindDateStr, @1, @1, @0, @0, writeDateStr, @(SSJSyncVersion()), @0]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table BK_USER add CEMAIL text"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserChargeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table BK_USER_CHARGE add LOANID text"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateBillTypeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"insert into BK_BILL_TYPE (ID, CNAME, ITYPE, CCOIN, CCOLOR, ISTATE, ICUSTOM) values ('5', '借贷利息收入', 0, 'bt_interest', '#408637', 2, 0)"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into BK_BILL_TYPE (ID, CNAME, ITYPE, CCOIN, CCOLOR, ISTATE, ICUSTOM) values ('6', '借贷利息支出', 1, 'bt_interest', '#408637', 2, 0)"]) {
        return [db lastError];
    }
    
    return nil;
}

@end
