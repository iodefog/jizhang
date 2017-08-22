//
//  SSJRecycleSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleSyncTable.h"

@implementation SSJRecycleSyncTable

+ (NSString *)tableName {
    return @"bk_recycle";
}

+ (NSArray *)columns {
    return @[@"rid",
             @"cuserid",
             @"cid",
             @"itype",
             @"clientadddate",
             @"cwritedate",
             @"operatortype",
             @"iversion"];
}

+ (NSArray *)primaryKeys {
    return @[@"rid"];
}

@end
