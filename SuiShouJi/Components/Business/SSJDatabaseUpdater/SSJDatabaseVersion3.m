//
//  SSJDatabaseVersion3.m
//  SuiShouJi
//
//  Created by old lang on 16/5/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion3.h"
#import <FMDB/FMDB.h>

@implementation SSJDatabaseVersion3

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self upgradeBillTypeTableWithDatabase:db];;
    if (error) {
        return error;
    }
    
    error = [self upgradeUserBillTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)upgradeBillTypeTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"icustom" inTableWithName:@"bk_bill_type"]) {
        if (![db executeUpdate:@"alter table bk_bill_type add icustom integer"]) {
            return [db lastError];
        }
    }
    
    if (![db columnExists:@"cparent" inTableWithName:@"bk_bill_type"]) {
        if (![db executeUpdate:@"alter table bk_bill_type add cparent text"]) {
            return [db lastError];
        }
    }
    
    if (![db columnExists:@"defaultOrder" inTableWithName:@"bk_bill_type"]) {
        if (![db executeUpdate:@"alter table bk_bill_type add defaultOrder integer"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)upgradeUserBillTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"iorder" inTableWithName:@"bk_user_bill"]) {
        if (![db executeUpdate:@"alter table bk_user_bill add iorder integer"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

@end
