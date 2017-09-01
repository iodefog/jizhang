//
//  SSJShareBooksFriendMarkSyncTable.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksFriendMarkSyncTable.h"

@implementation SSJShareBooksFriendMarkSyncTable

+ (NSString *)tableName {
    return @"bk_share_books_friends_mark";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"cuserid",
            @"cbooksid",
            @"cfriendid",
            @"cmark",
            @"iversion",
            @"cwritedate",
            @"operatortype",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObjects:
            @"cuserid",
            @"cbooksid",
            @"cfriendid",
            nil];
}

@end
