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

+ (NSArray *)columns {
    return @[@"cremindid",
             @"cuserid",
             @"cremindname",
             @"cmemo",
             @"cstartdate",
             @"istate",
             @"itype",
             @"icycle",
             @"iisend",
             @"ooperatortype",
             @"iversion",
             @"cwritedate"];
}

+ (NSArray *)primaryKeys {
    return @[@"cremindid"];
}

@end
