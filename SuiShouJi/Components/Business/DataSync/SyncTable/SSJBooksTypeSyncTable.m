//
//  SSJBooksTypeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeSyncTable.h"

@implementation SSJBooksTypeSyncTable

+ (NSString *)tableName {
    return @"bk_books_type";
}

+ (NSArray *)columns {
    return @[@"cbooksid",
             @"cuserid",
             @"cbooksname",
             @"cbookscolor",
             @"cwritedate",
             @"operatortype",
             @"iparenttype",
             @"iversion",
             @"iorder",
             @"cicoin"];
}

+ (NSArray *)primaryKeys {
    return @[@"cbooksid", @"cuserid"];
}

+ (NSDictionary *)fieldMapping {
    return @{@"cicoin":@"cicon"};
}

+ (BOOL)subjectToDeletion {
    return NO;
}

@end
