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

+ (NSString *)additionalConditionForMergeRecord:(NSDictionary *)record {
    return [NSString stringWithFormat:@"(select count(*) from BK_USER_BILL where CUSERID = '%@' and CBILLID = '%@') > 0 and (select count(*) from BK_FUND_INFO where CUSERID = '%@' and CFUNDID = '%@') > 0", record[@"cuserid"], record[@"ibillid"], record[@"cuserid"], record[@"ifunsid"]];
}

@end
