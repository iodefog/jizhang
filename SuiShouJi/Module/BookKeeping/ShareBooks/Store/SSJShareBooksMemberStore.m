//
//  SSJShareBooksMemberStore.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMemberStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJShareBooksMemberStore

+ (void)queryMemberItemWithMemberId:(NSString *)memberId
                            booksId:(NSString *)booksId
                            Success:(void(^)(SSJUserItem * memberItem))success
                            failure:(void (^)(NSError *error))failure {
    if (memberId.length) {
        SSJPRINT(@"memberid不正确");
    }
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select bm.cicon, bf.cmark from bk_share_books_member bm,bk_share_books_friends_mark bf where bm.cmemberid = ? and bm.cmemberid = bf.cfriendid and bm.cbooksid = ? and bm.cbooksid = bf.cbooksid",memberId,booksId];
        if (!rs) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        SSJUserItem *memberItem = [[SSJUserItem alloc] init];
        
        while ([rs next]) {
            memberItem.nickName = [rs stringForColumn:@"cmark"];
            memberItem.icon = [rs stringForColumn:@"cicon"];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(memberItem);
            });
        }
    }];
}

@end
