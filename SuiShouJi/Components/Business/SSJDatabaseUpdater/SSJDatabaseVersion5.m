//
//  SSJDatabaseVersion5.m
//  SuiShouJi
//
//  Created by old lang on 16/7/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion5.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion5

+ (NSString *)dbVersion {
    return @"unknown";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self updateUserTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"logintype" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add logintype integer"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

@end
