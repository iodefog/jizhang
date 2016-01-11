//
//  SSJUserChargeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserChargeSyncTable.h"

@implementation SSJUserChargeSyncTable

+ (NSString *)tableName {
    return @"BK_USER_CHARGE";
}

+ (NSArray *)columns {
    return @[@"ICHARGEID", @"IMONEY", @"IBILLID", @"IFID", @"CADDDATE", @"IOLDMONEY", @"IBALANCE", @"CBILLDATE", @"CUSERID", @"CWRITEDATE", @"IVERSION", @"OPERATORTYPE"];
}

+ (NSArray *)primaryKeys {
    return @[@"ICHARGEID"];
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db {
    if (![super shouldMergeRecord:record inDatabase:db]) {
        return NO;
    }
    
    FMResultSet *result = [db executeQuery:@"select count(*) from BK_USER_BILL where CUSERID = ? and CBILLID = ?", record[@"CUSERID"], record[@"IBILLID"]];
    
    if (!result) {
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return NO;
    }
    
    [result next];
    if ([result intForColumnIndex:0] <= 0) {
        return NO;
    }
    
    result = [db executeQuery:@"select count(*) from BK_FUND_INFO where CUSERID = ? and CFUNDID = ?", record[@"CUSERID"], record[@"IFID"]];
    
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
