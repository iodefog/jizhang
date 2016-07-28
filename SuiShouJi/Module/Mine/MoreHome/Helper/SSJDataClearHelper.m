//
//  SSJDataClearManager.m
//  SuiShouJi
//
//  Created by ricky on 16/7/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataClearHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserItem.h"
#import "SSJUserTableManager.h"
#import "SSJClearUserDataService.h"
#import "SSJUserDefaultDataCreater.h"

@implementation SSJDataClearHelper

+ (void)clearLocalDataWithSuccess:(void(^)())success
                          failure:(void (^)(NSError *error))failure{
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
    }];
}

+ (void)clearAllDataWithSuccess:(void(^)())success
                        failure:(void (^)(NSError *error))failure{
    NSString *originalUserid = SSJUSERID();
    NSString *newUserId = SSJUUID();
    SSJUserItem *userItem = [SSJUserTableManager queryUserItemForID:originalUserid];
    userItem.userId = newUserId;
    userItem.defaultMemberState = 0;
    userItem.defaultFundAcctState = 0;
    userItem.defaultBooksTypeState = 0;
    SSJClearUserDataService *service = [[SSJClearUserDataService alloc]initWithDelegate:nil];
    [service clearUserDataWithOriginalUserid:originalUserid newUserid:newUserId Success:^{
        [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithSuccess:^{
            if (SSJSetUserId(newUserId) && [SSJUserTableManager saveUserItem:userItem]) {
                if (success) {
                    success();
                }
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}
@end
