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
//    return @"BK_USER_BILL";
    return @"bk_user_bill";
}

+ (NSArray *)columns {
//    return @[@"CBILLID", @"CUSERID", @"CWRITEDATE", @"IVERSION", @"OPERATORTYPE"];
    return @[@"cbillid", @"cuserid", @"cwritedate", @"iversion", @"operatortype"];
}

+ (NSArray *)primaryKeys {
//    return @[@"CBILLID", @"CUSERID"];
    return @[@"cbillid", @"cuserid"];
}

//+ (BOOL)shouMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db {
//    FMResultSet *result = [db executeQuery:@"select count(*) from BK_BILL_TYPE where ID = ?", record[@"CBILLID"]];
//    if (!result) {
//        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
//        return NO;
//    }
//    
//    [result next];
//    if ([result intForColumnIndex:0] <= 0) {
//        return NO;
//    }
//    
//    return YES;
//}

+ (NSString *)additionalConditionForMergeRecord:(NSDictionary *)record {
    return [NSString stringWithFormat:@"(select count(*) from BK_BILL_TYPE where ID = '%@') > 0", record[@"CBILLID"]];
}

@end
