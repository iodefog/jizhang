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
    return @[@"cfundid",
             @"cacctname",
             @"cicoin",
             @"cparent",
             @"ccolor",
             @"cmemo",
             @"cuserid",
             @"iorder",
             @"idisplay",
             @"cwritedate",
             @"iversion",
             @"operatortype"];
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

+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    return [db boolForQuery:@"select count(*) from BK_FUND_INFO where CFUNDID = ?", record[@"cparent"]];
}

@end
