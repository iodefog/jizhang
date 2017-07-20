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

+ (NSArray *)columns {
    return @[@"wishid",
             @"cuserid",
             @"wishname",
             @"wishimage",
             @"iversion",
             @"cwritedate",
             @"operatortype",
             @"status",
             @"remindid",
             @"startdate",
             @"enddate",
             @"wishtype"];
}

+ (NSArray *)primaryKeys {
    return @[@"wishid"];
}
@end
