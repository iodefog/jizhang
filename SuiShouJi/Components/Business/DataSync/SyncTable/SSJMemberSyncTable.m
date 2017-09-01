//
//  SSJMemberSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/7/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberSyncTable.h"

@implementation SSJMemberSyncTable

+ (NSString *)tableName {
    return @"bk_member";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"cmemberid",
            @"cname",
            @"cuserid",
            @"ccolor",
            @"istate",
            @"iorder",
            @"cwritedate",
            @"operatortype",
            @"iversion",
            @"cadddate",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObjects:
            @"cmemberid",
            @"cuserid",
            nil];
}

@end
