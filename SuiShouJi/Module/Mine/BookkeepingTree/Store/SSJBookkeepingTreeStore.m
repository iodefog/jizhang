//
//  SSJBookkeepingTreeStore.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeStore.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJDatabaseQueue.h"

@implementation SSJBookkeepingTreeStore

+ (void)queryCheckInInfoWithUserId:(NSString *)userId success:(void(^)(SSJBookkeepingTreeCheckInModel *model))success failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select isignin, isignindate, hasshaked, treeimgurl, treegifurl from bk_user_tree where cuserid = ?", userId];
        if (!result) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJBookkeepingTreeCheckInModel *model = nil;
        while ([result next]) {
            SSJBookkeepingTreeCheckInModel *tmodel = [[SSJBookkeepingTreeCheckInModel alloc] init];
            tmodel.checkInTimes = [result intForColumn:@"isignin"];
            tmodel.lastCheckInDate = [result stringForColumn:@"isignindate"];
            tmodel.hasShaked = [result boolForColumn:@"hasshaked"];
            tmodel.treeImgUrl = [result stringForColumn:@"treeimgurl"];
            tmodel.treeGifUrl = [result stringForColumn:@"treegifurl"];
            tmodel.userId = userId;
            model = tmodel;
        }
        [result close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(model);
            });
        }
    }];
}

+ (void)saveCheckInModel:(SSJBookkeepingTreeCheckInModel *)model success:(void(^)())success failure:(void(^)(NSError *error))failure {
    if (!model) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"model不能为nil"}]);
            });
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        BOOL successfull = YES;
        BOOL hasRecord = [db boolForQuery:@"select count(*) from bk_user_tree where cuserid = ?", model.userId];
        if (hasRecord) {
            successfull = [db executeUpdate:@"update bk_user_tree set isignin = ?, isignindate = ?, hasshaked = ?, treeimgurl = ?, treegifurl = ? where cuserid = ?", @(model.checkInTimes), model.lastCheckInDate, @(model.hasShaked), model.treeImgUrl, model.treeGifUrl, model.userId];
        } else {
            successfull = [db executeUpdate:@"insert into bk_user_tree (isignin, isignindate, hasshaked, treeimgurl, treegifurl, cuserid) values (?, ?, ?, ?, ? ,?)", @(model.checkInTimes), model.lastCheckInDate, @(model.hasShaked), model.treeImgUrl, model.treeGifUrl, model.userId];
        }
        if (successfull) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
        } else {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
        }
    }];
}

@end
