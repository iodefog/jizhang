//
//  SSJUserCreditSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserCreditSyncTable.h"

@implementation SSJUserCreditSyncTable

+ (NSString *)tableName {
    return @"bk_user_credit";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"cfundid",
            @"iquota",
            @"cbilldate",
            @"crepaymentdate",
            @"cremindid",
            @"cuserid",
            @"cwritedate",
            @"iversion",
            @"operatortype",
            @"ibilldatesettlement",
            @"itype",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"cfundid"];
}

- (instancetype)init {
    if (self = [super init]) {
        self.subjectToDeletion = NO;
    }
    return self;
}

@end
