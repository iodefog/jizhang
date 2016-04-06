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
        
        [result next];
        checkInTimes = [result intForColumn:@"isignin"];
        lastCheckInDate = [result stringForColumn:@"isignindate"];
        hasShaked = [result boolForColumn:@"hasshaked"];
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

@end
