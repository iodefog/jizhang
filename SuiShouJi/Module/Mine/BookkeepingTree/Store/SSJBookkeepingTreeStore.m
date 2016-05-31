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

+ (SSJBookkeepingTreeCheckInModel *)queryCheckInInfoWithUserId:(NSString *)userId error:(NSError **)error{
    __block SSJBookkeepingTreeCheckInModel *model = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select isignin, isignindate, hasshaked, treeimgurl, treegifurl from bk_user_tree where cuserid = ?", userId];
        if (!result && error) {
            *error = [db lastError];
        }
        
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
    }];
    
    if (error && *error) {
        return nil;
    }
    
    return model;
}

+ (BOOL)saveCheckInModel:(SSJBookkeepingTreeCheckInModel *)model error:(NSError **)error {
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        BOOL hasRecord = [db boolForQuery:@"select count(*) from bk_user_tree where cuserid = ?", model.userId];
        if (hasRecord) {
            success = [db executeUpdate:@"update bk_user_tree set isignin = ?, isignindate = ?, hasshaked = ?, treeimgurl = ?, treegifurl = ? where cuserid = ?", @(model.checkInTimes), model.lastCheckInDate, @(model.hasShaked), model.treeImgUrl, model.treeGifUrl, model.userId];
        } else {
            success = [db executeUpdate:@"insert into bk_user_tree (isignin, isignindate, hasshaked, treeimgurl, treegifurl, cuserid) values (?, ?, ?, ?, ? ,?)", @(model.checkInTimes), model.lastCheckInDate, @(model.hasShaked), model.treeImgUrl, model.treeGifUrl, model.userId];
        }
        if (!success && error) {
            *error = [db lastError];
        }
    }];
    
    return success;
}

@end
