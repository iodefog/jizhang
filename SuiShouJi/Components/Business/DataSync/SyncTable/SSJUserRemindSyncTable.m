//
//  SSJUserRemindSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserRemindSyncTable.h"

@implementation SSJUserRemindSyncTable

+ (NSString *)tableName {
    return @"bk_user_remind";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"cremindid",
            @"cuserid",
            @"cremindname",
            @"cmemo",
            @"cstartdate",
            @"istate",
            @"itype",
            @"icycle",
            @"iisend",
            @"operatortype",
            @"iversion",
            @"cwritedate",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"cremindid"];
}

- (instancetype)init {
    if (self = [super init]) {
        self.subjectToDeletion = NO;
    }
    return self;
}

@end
