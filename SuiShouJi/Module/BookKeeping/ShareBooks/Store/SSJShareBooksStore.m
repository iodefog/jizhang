//
//  SSJShareBooksStore.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJShareBookMemberItem.h"

@implementation SSJShareBooksStore

+ (void)queryTheMemberListForTheShareBooks:(SSJShareBookItem *)booksItem
                                   Success:(void(^)(NSArray <SSJShareBookMemberItem *>* result))success
                                   failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        FMResultSet *resultSet = [db executeQuery:@"select bm.* , sk.cmark from bk_share_books_member bm, bk_share_books sk where bm.cbooksid = ? and bm.istate = 1 and sk.cuserid = ? and sk.cbooksid = bm.cbooksid and sk.cfreindid = bm.cmemberid",booksItem.booksId];
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
            memberItem.joinDate = [resultSet stringForColumn:@"cjoindate"];
            memberItem.state = [resultSet stringForColumn:@"istate"];
            memberItem.nickName = [resultSet stringForColumn:@"cmark"];
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
