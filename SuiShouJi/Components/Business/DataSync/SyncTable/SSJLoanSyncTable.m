//
//  SSJLoanSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/8/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanSyncTable.h"

@implementation SSJLoanSyncTable

+ (NSString *)tableName {
    return @"bk_loan";
}

+ (NSArray *)columns {
    return @[@"loanid", @"cuserid", @"lender", @"jmoney", @"cthefundid", @"ctargetfundid", @"cthecharge", @"ctargetcharge", @"cborrowdate", @"crepaymentdate", @"cenddate", @"rate", @"memo", @"cremindid", @"interest", @"iend", @"itype", @"operatorType", @"iversion", @"cwritedate"];
}

+ (NSArray *)primaryKeys {
    return @[@"loanid"];
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    return [db boolForQuery:@"select count(*) from BK_FUND_INFO where CFUNDID = ?", record[@"cparent"]];
}

@end
