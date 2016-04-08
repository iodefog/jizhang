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
    __block NSInteger checkInTimes = 0;
    __block NSString *lastCheckInDate = nil;
    __block BOOL hasShaked = NO;
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select isignin, isignindate, hasshaked from bk_user_tree where cuserid = ?", userId];
        if (!result) {
            *error = [db lastError];
        }
        
        while ([result next]) {
            checkInTimes = [result intForColumn:@"isignin"];
            lastCheckInDate = [result stringForColumn:@"isignindate"];
            hasShaked = [result boolForColumn:@"hasshaked"];
        }
        [result close];
    }];
    
    if (error) {
        return nil;
    }
    
    SSJBookkeepingTreeCheckInModel *model = [[SSJBookkeepingTreeCheckInModel alloc] init];
    model.checkInTimes = checkInTimes;
    model.lastCheckInDate = lastCheckInDate;
    model.userId = userId;
    model.hasShaked = hasShaked;
    return model;
}

+ (BOOL)saveCheckInModel:(SSJBookkeepingTreeCheckInModel *)model error:(NSError **)error {
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        BOOL hasRecord = [db boolForQuery:@"select count(*) from bk_user_tree where cuserid = ?", model.userId];
        if (hasRecord) {
            success = [db executeUpdate:@"update bk_user_tree set isignin = ?, isignindate = ?, hasshaked = ? where cuserid = ?", @(model.checkInTimes), model.lastCheckInDate, @(model.hasShaked), model.userId];
        } else {
            success = [db executeUpdate:@"insert into bk_user_tree (isignin, isignindate, hasshaked, cuserid) values (?, ?, ?, ?)", @(model.checkInTimes), model.lastCheckInDate, @(model.hasShaked), model.userId];
        }
        if (!success) {
            *error = [db lastError];
        }
    }];
    
    return success;
}

@end
