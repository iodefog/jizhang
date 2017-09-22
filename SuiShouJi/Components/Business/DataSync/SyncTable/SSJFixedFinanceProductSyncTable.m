//
//  SSJFixedFinanceProductSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 2017/9/6.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductSyncTable.h"

@implementation SSJFixedFinanceProductSyncTable

+ (NSString *)tableName {
    return @"bk_fixed_finance_product";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"cproductid",
            @"cuserid",
            @"cproductname",
            @"cmemo",
            @"cthisfundid",
            @"ctargetfundid",
            @"cetargetfundid",
            @"imoney",
            @"irate",
            @"iratetype",
            @"itime",
            @"itimetype",
            @"interesttype",
            @"cstartdate",
            @"cenddate",
            @"isend",
            @"cremindid",
            @"cwritedate",
            @"iversion",
            @"operatortype",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"cproductid"];
}

- (instancetype)init {
    if (self = [super init]) {
        self.subjectToDeletion = NO;
    }
    return self;
}

@end
