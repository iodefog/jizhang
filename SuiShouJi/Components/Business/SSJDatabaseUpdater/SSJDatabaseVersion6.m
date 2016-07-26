//
//  SSJDatabaseVersion6.m
//  SuiShouJi
//
//  Created by old lang on 16/7/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion6.h"

@implementation SSJDatabaseVersion6

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self createMemberTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createMemberChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)createMemberTableWithDatabase:(FMDatabase *)db {
    return nil;
}

+ (NSError *)createMemberChargeTableWithDatabase:(FMDatabase *)db {
    return nil;
}

@end
