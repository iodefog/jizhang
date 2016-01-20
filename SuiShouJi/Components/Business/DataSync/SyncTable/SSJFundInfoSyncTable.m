//
//  SSJFundInfoSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundInfoSyncTable.h"

@implementation SSJFundInfoSyncTable

+ (NSString *)tableName {
    return @"bk_fund_info";
}

+ (NSArray *)columns {
    return @[@"cfundid", @"cacctname", @"cicoin", @"cparent", @"ccolor", @"cmemo", @"cuserid", @"cwritedate", @"iversion", @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"cfundid"];
}

+ (NSString *)queryRecordsForSyncAdditionalCondition {
    return @"cparent <> 'root'";
}

+ (NSString *)updateSyncVersionAdditionalCondition {
    return @"cparent <> 'root'";
}

+ (NSString *)additionalConditionForMergeRecord:(NSDictionary *)record {
    return [NSString stringWithFormat:@"(select count(*) from BK_FUND_INFO where CFUNDID = '%@') > 0", record[@"CPARENT"]];
}

@end
