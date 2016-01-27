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
    return @"bk_user_charge";
}

+ (NSArray *)columns {
    return @[@"ichargeid", @"imoney", @"ibillid", @"ifunsid", @"cadddate", @"ioldmoney", @"ibalance", @"cbilldate", @"cuserid", @"cwritedate", @"iversion", @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"ichargeid"];
}

+ (BOOL)shouldInsertForMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db {
    BOOL hasBillType = [db boolForQuery:@"select count(*) from BK_USER_BILL where CUSERID = ? and CBILLID = ?", record[@"cuserid"], record[@"ibillid"]];
    BOOL hasFundAccount = [db boolForQuery:@"select count(*) from BK_FUND_INFO where CUSERID = ? and CFUNDID = ?", record[@"cuserid"], record[@"ifunsid"]];
    return (hasBillType && hasFundAccount);
}

@end
