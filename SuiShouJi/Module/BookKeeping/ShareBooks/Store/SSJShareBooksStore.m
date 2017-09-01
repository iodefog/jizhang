//
//  SSJShareBooksStore.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserChargeSyncTable.h"
#import "SSJShareBooksMemberSyncTable.h"

@implementation SSJShareBooksStore

+ (void)queryTheMemberListForTheShareBooks:(SSJShareBookItem *)booksItem
                                   Success:(void(^)(NSArray <SSJShareBookMemberItem *>* result))success
                                   failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *userId = SSJUSERID();
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        FMResultSet *resultSet = [db executeQuery:@"select bm.* , bf.cmark from bk_share_books_member bm left join bk_share_books_friends_mark bf on bf.cfriendid = bm.cmemberid and bf.cbooksid = bm.cbooksid and bf.cuserid = ? where bm.istate = ? and bm.cbooksid = ? order by bm.cjoindate asc",userId,@(SSJShareBooksMemberStateNormal),booksItem.booksId,booksItem.booksId];
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
            memberItem.adminId = booksItem.adminId;
            memberItem.icon = [resultSet stringForColumn:@"cicon"];
            memberItem.joinDate = [resultSet stringForColumn:@"cjoindate"];
            memberItem.state = [resultSet boolForColumn:@"istate"];
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

+ (void)kickOutMembersWithWithShareCharge:(NSArray *)shareChargeArray
                              shareMember:(NSArray *)shareMemberArray
                                  Success:(void(^)())success
                                  failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSError *tError;
        if (![[SSJUserChargeSyncTable table] mergeRecords:shareChargeArray forUserId:SSJUSERID() inDatabase:db error:&tError]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        };
        
        if (![[SSJShareBooksMemberSyncTable table] mergeRecords:shareMemberArray forUserId:SSJUSERID() inDatabase:db error:&tError]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        };
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

@end
