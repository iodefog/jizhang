//
//  SSJShareBooksSyncTable.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksSyncTable.h"

@implementation SSJShareBooksSyncTable

+ (NSString *)tableName {
    return @"bk_share_books";
}

+ (NSArray *)columns {
    return @[@"cbooksid",
             @"ccreator",
             @"cadmin",
             @"cbooksname",
             @"cbookscolor",
             @"iparenttype",
             @"iversion",
             @"cwritedate",
             @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"cbooksid"];
}


@end
