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
    return @"BK_USER_BILL";
}

+ (NSArray *)columns {
    return @[@"CBILLID", @"CUSERID", @"CWRITEDATE", @"IVERSION", @"OPERATORTYPE"];
}

+ (NSArray *)primaryKeys {
    return @[@"CBILLID", @"CUSERID"];
}

+ (BOOL)shouMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db {
    FMResultSet *result = [db executeQuery:@"select count(*) from BK_BILL_TYPE where ID = ?", record[@"CBILLID"]];
    if (!result) {
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return NO;
    }
    
    [result next];
    if ([result intForColumnIndex:0] <= 0) {
        return NO;
    }
    
    return YES;
}

@end
