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
    return @[@"loanid",
             @"cuserid",
             @"lender",
             @"jmoney",
             @"cthefundid",
             @"ctargetfundid",
             @"cetarget",
             @"cthecharge",
             @"ctargetcharge",
             @"cethecharge",
             @"cetargetcharge",
             @"cinterestid",
             @"cborrowdate",
             @"crepaymentdate",
             @"cenddate",
             @"rate",
             @"memo",
             @"cremindid",
             @"interest",
             @"iend",
             @"itype",
             @"operatorType",
             @"iversion",
             @"cwritedate"];
}

+ (NSArray *)primaryKeys {
    return @[@"loanid"];
}

@end
