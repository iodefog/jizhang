//
//  SSJShareBooksStore.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJShareBooksStore

+ (void)queryTheMemberListForTheShareBooks:(SSJShareBookItem *)booksItem
                                   Success:(void(^)(NSArray <SSJShareBookMemberItem *>* result))success
                                   failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *userId = SSJUSERID();
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        FMResultSet *resultSet = [db executeQuery:@"select bm.* , bf.cmark from bk_share_books_friends_mark bf, bk_share_books_member bm where bm.istate = 1 and bf.cfriendid = bm.cmemberid and bm.cbooksid = ? order by bm.cjoindate desc",booksItem.booksId];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        while ([resultSet next]) {
            SSJShareBookMemberItem *memberItem = [[SSJShareBookMemberItem alloc] init];
            memberItem.memberId = [resultSet stringForColumn:@"cmemberid"];
            memberItem.booksId = [resultSet stringForColumn:@"cbooksid"];
            memberItem.icon = [resultSet stringForColumn:@"cicon"];
            memberItem.joinDate = [resultSet stringForColumn:@"cjoindate"];
            memberItem.state = [resultSet stringForColumn:@"istate"];
            memberItem.nickName = [resultSet stringForColumn:@"cmark"];
            [tempArr addObject:memberItem];
        }
        
        
        if ([booksItem.adminId isEqualToString:userId]) {
            SSJShareBookMemberItem *memberItem = [[SSJShareBookMemberItem alloc] init];
            memberItem.memberId = @"-1";
            [tempArr addObject:memberItem];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArr);
            });
        }
    }];
}

@end
