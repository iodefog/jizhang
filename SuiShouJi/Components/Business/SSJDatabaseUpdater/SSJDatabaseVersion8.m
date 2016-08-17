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
    
    return nil;
}

+ (NSError *)updateFundInfoTableAndFunsAcctTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table bk_fund_info add idisplay integer default 1"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_fund_info set cacctname = '借出款', cmemo = '应收钱款' where cfundid = '9'"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", @"10", @"借出款", @"", @"root", @"-1", @"0"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", @"11", @"欠款", @"", @"root", @"-1", @"0"]) {
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
        
        if (![db executeUpdate:@"insert into BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN, IORDER) values (?, '借出款', '10', '', ?, 0, ?, ?, '', ?)", lendFundID, writeDate, @(SSJSyncVersion()), userId, @(maxOrder + 1)]) {
            return [db lastError];
        }
        
        if (![db executeUpdate:@"insert into BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN, IORDER) values (?, '欠款', '11', '', ?, 0, ?, ?, '', ?)", borrowFundID, writeDate, @(SSJSyncVersion()), userId, @(maxOrder + 2)]) {
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
    if (![db executeUpdate:@"create table if not exists BK_LOAN (LOANID text not null, CUSERID text, LENDER text, JMONEY numeric, CTHEFUNDID text, CTARGETFUNDID text, CBORROWDATE text, CREPAYMENTDATE text, RATE numeric, MEMO text, INTEREST integer, CREMINDID text, CWRITEDATE text, IVERSION integer, OPERATORTYPE integer, IEND integer, ITYPE integer, primary key(LOANID))"]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)createUserCreditTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_USER_CREDIT (CFUNDID TEXT NOT NULL, IQUOTA NUMERIC, CBILLDATE TEXT, CREPAYMENTDATE TEXT, CWRITEDATE TEXT, IVERSION INTEGER, OPERATORTYPE INTEGER, CREMINDID TEXT, IDELAYDATE INTEGER, IISEND INTEGER, PRIMARY KEY(CFUNDID))"]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)createUserRemindTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_USER_REMIND (CREMINDID TEXT NOT NULL, CUSERID TEXT, CREMINDNAME TEXT, CMEMO TEXT, CCLOCK TEXT, CSTARTDATE TEXT, ISTATE INTEGER, ITYPE INTEGER, CWRITEDATE TEXT, IVERSION INTEGER, OPERATORTYPE INTEGER, PRIMARY KEY(CREMINDID))"]) {
        return [db lastError];
    }
    
    return nil;
}

@end
