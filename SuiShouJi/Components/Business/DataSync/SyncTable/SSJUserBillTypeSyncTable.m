//
//  SSJUserBillTypeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserBillTypeSyncTable.h"

@implementation SSJUserBillTypeSyncTable

+ (NSString *)tableName {
    return @"bk_user_bill_type";
}

+ (NSArray *)columns {
    return @[@"cbillid",
             @"cuserid",
             @"cbooksid",
             @"itype",
             @"cname",
             @"ccolor",
             @"cicoin",
             @"cwritedate",
             @"operatortype",
             @"iversion"];
}

+ (NSArray *)primaryKeys {
    return @[@"cbillid", @"cuserid", @"cbooksid"];
}

@end
