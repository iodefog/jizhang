//
//  SSJDatabaseVersion8.m
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion8.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion8

+ (NSString *)dbVersion {
    return @"1.7.0";
}

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
    
    error = [self updateBooksTypeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateSyncTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)updateSyncTableWithDatabase:(FMDatabase *)db {
    NSString *userId = SSJUSERID();
    if (![db executeUpdate:@"delete from bk_sync where cuserid = ?",userId]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateFundInfoTableAndFunsAcctTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"idisplay" inTableWithName:@"bk_fund_info"]) {
        if (![db executeUpdate:@"alter table bk_fund_info add idisplay integer default 1"]) {
            return [db lastError];
        }
    }
    
    if (![db executeUpdate:@"update bk_fund_info set cacctname = '借出款', cmemo = '应收钱款' where cfundid = '9'"]) {
        return [db lastError];
    }
    
    if (![db boolForQuery:@"select count(1) from bk_fund_info where cfundid = '10'"]) {
        if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype, cmemo) values (?, ?, ?, ?, ?, ?, ?)", @"10", @"借出款", @"ft_jiechukuan", @"root", @"-1", @"0", @"应收钱款"]) {
            return [db lastError];
        }
    }
    
    if (![db boolForQuery:@"select count(1) from bk_fund_info where cfundid = '11'"]) {
        if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", @"11", @"欠款", @"ft_qiankuan", @"root", @"-1", @"0"]) {
            return [db lastError];
        }
    }
    
    if (![db boolForQuery:@"select count(1) from bk_fund_info where cfundid = '12'"]) {
        if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype, cmemo) values (?, ?, ?, ?, ?, ?, ?)", @"12", @"社保", @"ft_shebao", @"root", @"-1", @"0", @"医保"]) {
            return [db lastError];
        }
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
        
        if (![db boolForQuery:@"select count(1) from BK_FUND_INFO where CFUNDID = ?", lendFundID]) {
            if (![db executeUpdate:@"insert into BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN, IORDER) values (?, '借出款', '10', '#a883d8', ?, 0, ?, ?, 'ft_jiechukuan', ?)", lendFundID, writeDate, @(SSJSyncVersion()), userId, @(maxOrder + 1)]) {
                return [db lastError];
            }
        }
        
        if (![db boolForQuery:@"select count(1) from BK_FUND_INFO where CFUNDID = ?", borrowFundID]) {
            if (![db executeUpdate:@"insert into BK_FUND_INFO (CFUNDID, CACCTNAME, CPARENT, CCOLOR, CWRITEDATE, OPERATORTYPE, IVERSION, CUSERID, CICOIN, IORDER) values (?, '欠款', '11', '#ef6161', ?, 0, ?, ?, 'ft_qiankuan', ?)", borrowFundID, writeDate, @(SSJSyncVersion()), userId, @(maxOrder + 2)]) {
                return [db lastError];
            }
        }
        
        if (![db boolForQuery:@"select count(1) from BK_FUNS_ACCT where CFUNDID = ?", lendFundID]) {
            if (![db executeUpdate:@"insert into BK_FUNS_ACCT (CFUNDID, CUSERID, IBALANCE) values (?, ?, ?)", lendFundID, userId, @0.00]) {
                return [db lastError];
            }
        }
        
        if (![db boolForQuery:@"select count(1) from BK_FUNS_ACCT where CFUNDID = ?", borrowFundID]) {
            if (![db executeUpdate:@"insert into BK_FUNS_ACCT (CFUNDID, CUSERID, IBALANCE) values (?, ?, ?)", borrowFundID, userId, @0.00]) {
                return [db lastError];
            }
        }
    }
    
    return nil;
}

+ (NSError *)createLoanTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_LOAN (LOANID text not null, CUSERID text, LENDER text, JMONEY numeric, CTHEFUNDID text, CTARGETFUNDID text, CETARGET text, CBORROWDATE text, CREPAYMENTDATE text, CENDDATE text, RATE numeric, MEMO text, INTEREST integer, CREMINDID text, CWRITEDATE text, IVERSION integer, OPERATORTYPE integer, IEND integer, ITYPE integer, primary key(LOANID))"]) {
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
    // 之前数据库升级bug导致重复执行操作，补救措施
    [db executeUpdate:@"delete from bk_user_remind"];
    
    BOOL open = NO;
    NSString *time = nil;
    FMResultSet *result = [db executeQuery:@"select * from BK_CHARGE_REMINDER"];
    while ([result next]) {
        open = [result boolForColumn:@"ISONORNOT"];
        time = [result stringForColumn:@"TIME"];
    }
    [result close];
    
    NSString *remindDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
    remindDate = [NSString stringWithFormat:@"%@ %@:00", remindDate, time];
    
    if (open) {
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        result = [db executeQuery:@"select CUSERID from BK_USER"];
        while ([result next]) {
            NSString *userID = [result stringForColumn:@"CUSERID"];
            if (![db executeUpdate:@"insert into BK_USER_REMIND (CREMINDID, CUSERID, CREMINDNAME, CMEMO, CSTARTDATE, ISTATE, ITYPE, ICYCLE, IISEND, CWRITEDATE, IVERSION, OPERATORTYPE) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", SSJUUID(), userID, @"记账提醒", @"", remindDate, @1, @1, @0, @0, writeDateStr, @(SSJSyncVersion()), @0]) {
                return [db lastError];
            }
        }
    }
    
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"CEMAIL" inTableWithName:@"BK_USER"]) {
        if (![db executeUpdate:@"alter table BK_USER add CEMAIL text"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)updateUserChargeTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"LOANID" inTableWithName:@"BK_USER_CHARGE"]) {
        if (![db executeUpdate:@"alter table BK_USER_CHARGE add LOANID text"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)updateBillTypeTableWithDatabase:(FMDatabase *)db {
    if (![db boolForQuery:@"select count(1) from BK_BILL_TYPE where ID = '5'"]) {
        if (![db executeUpdate:@"insert into BK_BILL_TYPE (ID, CNAME, ITYPE, CCOIN, CCOLOR, ISTATE, ICUSTOM) values ('5', '借贷利息收入', 0, 'bt_interest', '#408637', 2, 0)"]) {
            return [db lastError];
        }
    }
    
    if (![db boolForQuery:@"select count(1) from BK_BILL_TYPE where ID = '6'"]) {
        if (![db executeUpdate:@"insert into BK_BILL_TYPE (ID, CNAME, ITYPE, CCOIN, CCOLOR, ISTATE, ICUSTOM) values ('6', '借贷利息支出', 1, 'bt_interest', '#408637', 2, 0)"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)updateBooksTypeTableWithDatabase:(FMDatabase *)db {
    FMResultSet *result = [db executeQuery:@"select cuserid from bk_user"];
    if (!result) {
        return [db lastError];
    }
    
    while ([result next]) {
        NSString *userID = [result stringForColumn:@"cuserid"];
        NSString *booksID1 = userID;
        NSString *booksID2 = [NSString stringWithFormat:@"%@-1", userID];
        NSString *booksID3 = [NSString stringWithFormat:@"%@-2", userID];
        NSString *booksID4 = [NSString stringWithFormat:@"%@-3", userID];
        NSString *booksID5 = [NSString stringWithFormat:@"%@-4", userID];
        
        if (![db executeUpdate:@"update bk_books_type set cicoin = 'bk_moren' where cbooksid = ? and cuserid = ?", booksID1, userID]) {
            [result close];
            return [db lastError];
        }
        
        if (![db executeUpdate:@"update bk_books_type set cicoin = 'bk_shengyi' where cbooksid = ? and cuserid = ?", booksID2, userID]) {
            [result close];
            return [db lastError];
        }
        
        if (![db executeUpdate:@"update bk_books_type set cicoin = 'bk_jiehun' where cbooksid = ? and cuserid = ?", booksID3, userID]) {
            [result close];
            return [db lastError];
        }
        
        if (![db executeUpdate:@"update bk_books_type set cicoin = 'bk_zhuangxiu' where cbooksid = ? and cuserid = ?", booksID4, userID]) {
            [result close];
            return [db lastError];
        }
        
        if (![db executeUpdate:@"update bk_books_type set cicoin = 'bk_lvxing' where cbooksid = ? and cuserid = ?", booksID5, userID]) {
            [result close];
            return [db lastError];
        }
        
        
        NSString *sqlStr = [NSString stringWithFormat:@"update bk_books_type set cicoin = 'bk_moren' where cbooksid not in ('%@', '%@', '%@', '%@', '%@') and cuserid = '%@'", booksID1, booksID2, booksID3, booksID4, booksID5, userID];
        if (![db executeUpdate:sqlStr]) {
            [result close];
            return [db lastError];
        }
    }
    [result close];
    
    return nil;
}

@end
