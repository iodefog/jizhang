//
//  SSJWishSyncTable.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishSyncTable.h"

@implementation SSJWishSyncTable
+ (NSString *)tableName {
    return @"bk_wish";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"wishid",
            @"cuserid",
            @"wishname",
            @"wishmoney",
            @"wishimage",
            @"iversion",
            @"cwritedate",
            @"operatortype",
            @"status",
            @"remindid",
            @"startdate",
            @"enddate",
            @"wishtype",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"wishid"];
}
@end
