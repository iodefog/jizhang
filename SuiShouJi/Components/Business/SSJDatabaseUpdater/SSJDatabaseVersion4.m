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
    return nil;
}

+ (NSError *)createBooksTypeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_books_type (cbooksid text not null, cbooksname text not null, cbookscolor text, cwritedate text, operatortype integer, iversion integer, cuserid text, primary key(cbooksid))"]) {
        return [db lastError];
    }
    
    return nil;
}

@end
