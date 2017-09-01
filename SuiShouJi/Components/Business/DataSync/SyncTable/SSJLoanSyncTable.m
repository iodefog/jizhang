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

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"loanid",
            @"cuserid",
            @"lender",
            @"jmoney",
            @"cthefundid",
            @"ctargetfundid",
            @"cetarget",
            @"cborrowdate",
            @"crepaymentdate",
            @"cenddate",
            @"rate",
            @"memo",
            @"cremindid",
            @"interest",
            @"interesttype",
            @"iend",
            @"itype",
            @"operatortype",
            @"iversion",
            @"cwritedate",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"loanid"];
}

- (instancetype)init {
    if (self = [super init]) {
        self.subjectToDeletion = NO;
    }
    return self;
}

@end
