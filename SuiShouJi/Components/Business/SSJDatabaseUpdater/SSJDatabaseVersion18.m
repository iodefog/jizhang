//
//  SSJDatabaseVersion18.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion18.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion18

+ (NSString *)dbVersion {
    return @"2.8.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self createRecycleTableWithDatabase:db];
    if (error) {
        return error;
    }
    return nil;
}

+ (NSError *)createRecycleTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS `BK_RECYCLE` (\
                                                        `RID`	TEXT,\
                                                        `CUSERID`	TEXT,\
                                                        `CID`	TEXT,\
                                                        `ITYPE`	INTEGER,\
                                                        `ISTATE`	INTEGER,\
                                                        `CLIENTADDDATE`	TEXT,\
                                                        `CWRITEDATE`	TEXT,\
                                                        `OPERATORTYPE`	INTEGER,\
                                                        `IVERSION`	INTEGER,\
                                                        PRIMARY KEY(RID)"]) {
        return [db lastError];
    }
    
    return nil;
}

@end
