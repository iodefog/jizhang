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

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"cbooksid",
            @"cuserid",
            @"cbooksname",
            @"cbookscolor",
            @"cwritedate",
            @"operatortype",
            @"iparenttype",
            @"iversion",
            @"iorder",
            @"cicoin",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObjects:
            @"cbooksid",
            @"cuserid",
            nil];
}

+ (NSDictionary *)fieldMapping {
    return @{@"cicoin":@"cicon"};
}

- (instancetype)init {
    if (self = [super init]) {
        self.subjectToDeletion = NO;
    }
    return self;
}

@end
