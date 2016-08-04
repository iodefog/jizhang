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
#import "SSJDataSynchronizer.h"

@implementation SSJDataClearHelper

+ (void)clearLocalDataWithSuccess:(void(^)())success
                          failure:(void (^)(NSError *error))failure{
    
    NSString *userId = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"delete from bk_member_charge where ichargeid in (select ichargeid from bk_user_charge where cuserid = ?)", userId]
            && [db executeUpdate:@"delete from bk_member where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_user_budget where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_user_charge where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_charge_period_config where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_fund_info where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_bill_type where id in (select cbillid from bk_user_bill where cuserid = ?) and icustom = 1", userId]
            && [db executeUpdate:@"delete from bk_user_bill where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_books_type where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_dailysum_charge where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_funs_acct where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_sync where cuserid = ?", userId]) {
            
            [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:^(SSJDataSynchronizeType type) {
                if (success) {
                    success();
                }
            } failure:^(SSJDataSynchronizeType type, NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        } else {
            if (failure) {
                failure([db lastError]);
            }
        }
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
        if (SSJSetUserId(newUserId) && [SSJUserTableManager saveUserItem:userItem]) {
            [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithSuccess:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success();
                    }
                });
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        failure(error);
                    }
                });
            }];
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}
@end
