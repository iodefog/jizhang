//
//  SSJDatabaseVersion7.m
//  SuiShouJi
//
//  Created by old lang on 16/8/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion7.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion7

+ (NSString *)dbVersion {
    return @"1.6.1";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self updateUserTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"lastselectfundid" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add lastselectfundid text"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

@end
