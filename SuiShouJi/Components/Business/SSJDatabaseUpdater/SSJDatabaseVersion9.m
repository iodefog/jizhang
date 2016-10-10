//
//  SSJDatabaseVersion9.m
//  SuiShouJi
//
//  Created by old lang on 16/10/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion9.h"
#import <FMDB/FMDB.h>

@implementation SSJDatabaseVersion9

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self createSearchHistoryTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createIndexOnUserChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)createSearchHistoryTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE BK_SEARCH_HISTORY (CUSERID TEXT NOT NULL, CSEARCHCONTENT TEXT NOT NULL, CHISTORYID TEXT NOT NULL, CSEARCHDATE TEXT, PRIMARY KEY(CUSERID, CHISTORYID))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)createIndexOnUserChargeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE INDEX UserIndex ON BK_USER_CHARGE (CUSERID)"]) {
        return [db lastError];
    }
    return nil;
}

@end
