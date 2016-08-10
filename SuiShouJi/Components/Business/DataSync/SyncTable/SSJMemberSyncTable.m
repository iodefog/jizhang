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

+ (NSArray *)columns {
    return @[@"cmemberid", @"cname", @"cuserid", @"ccolor", @"istate", @"cwritedate", @"operatortype", @"iversion", @"cadddate"];
}

+ (NSArray *)primaryKeys {
    return @[@"cmemberid", @"cuserid"];
}

@end
