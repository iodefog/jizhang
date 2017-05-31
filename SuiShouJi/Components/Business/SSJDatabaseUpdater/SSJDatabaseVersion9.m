//
//  SSJDatabaseVersion9.m
//  SuiShouJi
//
//  Created by old lang on 16/10/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion9.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion9

+ (NSString *)dbVersion {
    return @"1.8.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self createSearchHistoryTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateMemberTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateBudgetTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)createSearchHistoryTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_SEARCH_HISTORY (CUSERID TEXT NOT NULL, CSEARCHCONTENT TEXT NOT NULL, CHISTORYID TEXT NOT NULL, CSEARCHDATE TEXT, PRIMARY KEY(CUSERID, CHISTORYID))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserChargeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE INDEX IF NOT EXISTS UserIndex ON BK_USER_CHARGE (CUSERID)"]) {
        return [db lastError];
    }
    
    if (![db columnExists:@"CLIENTADDDATE" inTableWithName:@"BK_USER_CHARGE"]) {
        if (![db executeUpdate:@"ALTER TABLE BK_USER_CHARGE ADD CLIENTADDDATE TEXT"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)updateMemberTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"IORDER" inTableWithName:@"BK_MEMBER"]) {
        if (![db executeUpdate:@"ALTER TABLE BK_MEMBER ADD IORDER INTEGER"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

/**
 将历时预算全部改成总预算，当前预算中类别最多的作为总预算，其他作为分预算；这样处理是因为之前数据库升级有bug，导致app升级到1.8但是数据库没有做相应的版本更新操作，只能采用此方法作为补救措施
 */
+ (NSError *)updateBudgetTableWithDatabase:(FMDatabase *)db {
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 将所有有效的历史预算设置为总预算
    if (![db executeUpdate:@"UPDATE BK_USER_BUDGET SET CBILLTYPE = 'all', IVERSION = ?, CWRITEDATE = ?, OPERATORTYPE = 1 WHERE CEDATE < date('now', 'localtime') AND OPERATORTYPE <> 2", @(SSJSyncVersion()), writeDate]) {
        return [db lastError];
    }
    
    NSMutableArray *budgetIDs = [NSMutableArray array];
    NSMutableDictionary *userBudgetInfo = [NSMutableDictionary dictionary];
    
    // 查询所有用户不同账本下当前有效的预算
    FMResultSet *resultSet = [db executeQuery:@"SELECT IBID, ITYPE, CBILLTYPE, CUSERID, CBOOKSID FROM BK_USER_BUDGET WHERE CEDATE >= DATE('NOW', 'LOCALTIME') AND CSDATE <= DATE('NOW', 'LOCALTIME') AND OPERATORTYPE <> 2"];
    while ([resultSet next]) {
        int type = [resultSet intForColumn:@"ITYPE"];
        NSString *budgetId = [resultSet stringForColumn:@"IBID"];
        NSString *billType = [resultSet stringForColumn:@"CBILLTYPE"];
        NSArray *billTypes = [billType componentsSeparatedByString:@","];
        NSString *userId = [resultSet stringForColumn:@"CUSERID"];
        NSString *booksId = [resultSet stringForColumn:@"CBOOKSID"];
        
        NSString *key = [NSString stringWithFormat:@"%@+%@", userId, booksId];
        
        NSMutableArray *budgets = userBudgetInfo[key];
        if (!budgets) {
            budgets = [NSMutableArray array];
        }
        
        [budgets addObject:@{@"budgetId":budgetId,
                             @"type":@(type),
                             @"billTypes":billTypes}];
        
        [userBudgetInfo setObject:budgets forKey:key];
    }
    [resultSet close];
    
    // 遍历每个用户的账本，查找类别最多的预算（如果billtype是all，直接当作类别最多）
    [userBudgetInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *weekBudgetId = nil;
        NSString *monthBudgetId = nil;
        NSString *yearBudgetId = nil;
        
        NSUInteger weekBudgetTypeCount = 0;
        NSUInteger monthBudgetTypeCount = 0;
        NSUInteger yearBudgetTypeCount = 0;
        
        NSArray *budgets = obj;
        
        for (NSDictionary *budgetInfo in budgets) {
            int type = [budgetInfo[@"type"] intValue];
            NSArray *billTypes = budgetInfo[@"billTypes"];
            NSString *budgetId = budgetInfo[@"budgetId"];
            
            if (type == 0) {
                if ([billTypes isEqualToArray:@[SSJAllBillTypeId]]) {
                    weekBudgetId = budgetId;
                    weekBudgetTypeCount = NSUIntegerMax;
                } else {
                    weekBudgetId = weekBudgetTypeCount > billTypes.count ? weekBudgetId : budgetId;
                    weekBudgetTypeCount = billTypes.count;
                }
            } else if (type == 1) {
                if ([billTypes isEqualToArray:@[SSJAllBillTypeId]]) {
                    monthBudgetId = budgetId;
                    monthBudgetTypeCount = NSUIntegerMax;
                } else {
                    monthBudgetId = monthBudgetTypeCount > billTypes.count ? monthBudgetId : budgetId;
                    monthBudgetTypeCount = billTypes.count;
                }
            } else if (type == 2) {
                if ([billTypes isEqualToArray:@[SSJAllBillTypeId]]) {
                    yearBudgetId = budgetId;
                    yearBudgetTypeCount = NSUIntegerMax;
                } else {
                    yearBudgetId = yearBudgetTypeCount > billTypes.count ? yearBudgetId : budgetId;
                    yearBudgetTypeCount = billTypes.count;
                }
            }
        }
        
        if (weekBudgetId) {
            [budgetIDs addObject:[NSString stringWithFormat:@"'%@'", weekBudgetId]];
        }
        
        if (monthBudgetId) {
            [budgetIDs addObject:[NSString stringWithFormat:@"'%@'", monthBudgetId]];
        }
        
        if (yearBudgetId) {
            [budgetIDs addObject:[NSString stringWithFormat:@"'%@'", yearBudgetId]];
        }
    }];
    
    // 将类别最多的预算修改为总预算
    if (budgetIDs.count > 0) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE BK_USER_BUDGET SET CBILLTYPE = 'all', OPERATORTYPE = 1, IVERSION = ?, CWRITEDATE = ? WHERE IBID IN (%@)", [budgetIDs componentsJoinedByString:@","]];
        if (![db executeUpdate:sql, @(SSJSyncVersion()), writeDate]) {
            return [db lastError];
        }
    }
    
    return nil;
}

@end
