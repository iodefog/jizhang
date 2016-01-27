//
//  SSJUserBillSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserBillSyncTable.h"

@implementation SSJUserBillSyncTable

+ (NSString *)tableName {
    return @"bk_user_bill";
}

+ (NSArray *)columns {
    return @[@"cbillid", @"cuserid", @"cwritedate", @"iversion", @"operatortype", @"istate"];
}

+ (NSArray *)primaryKeys {
    return @[@"cbillid", @"cuserid"];
}

+ (NSString *)mergeConditionForUpdateRecord:(NSDictionary *)record {
    return [NSString stringWithFormat:@"(select count(*) from BK_BILL_TYPE where ID = '%@') > 0", record[@"cbillid"]];
}

+ (BOOL)shouldInsertForMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db {
    return [db boolForQuery:@"select count(*) from BK_BILL_TYPE where ID = ?", record[@"cbillid"]];
}

@end
