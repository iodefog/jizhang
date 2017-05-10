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
#import "SSJLoginViewController.h"
#import "SSJLoginViewController+SSJCategory.h"
#import "SSJLocalNotificationHelper.h"

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
            && [db executeUpdate:@"delete from bk_sync where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_credit_repayment where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_loan where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_user_credit where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_transfer_cycle where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_user_remind where cuserid = ?", userId]) {
              
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
    
    [SSJUserTableManager queryUserItemWithID:originalUserid success:^(SSJUserItem * _Nonnull originalUserItem) {
        originalUserItem.registerState = @"1";
        
        SSJUserItem *newuserItem = [originalUserItem copy];
        newuserItem.userId = newUserId;
        newuserItem.defaultMemberState = @"0";
        newuserItem.defaultFundAcctState = @"0";
        newuserItem.defaultBooksTypeState = @"0";
        newuserItem.currentBooksId = newuserItem.userId;
        
        // 老用户id没过注册过，说明没有登录，为登陆情况下数据格式化不请求接口
        if (SSJIsUserLogined()) {
            
            SSJClearUserDataService *service = [[SSJClearUserDataService alloc]initWithDelegate:nil];
            [service clearUserDataWithOriginalUserid:originalUserid newUserid:newUserId Success:^{
                
                if ([service.returnCode isEqualToString:@"-5555"]) {
                    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"数据已格式化成功，请重新登录！" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                        [SSJLoginViewController reloginIfNeeded];
                    }], nil];
                    return;
                }
                
                [self saveNewUserItem:newuserItem originalUserItem:originalUserItem success:success failure:failure];
                
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
            
        } else {
            [self saveNewUserItem:newuserItem originalUserItem:originalUserItem success:success failure:failure];
        }
    } failure:failure];
}

+ (void)saveNewUserItem:(SSJUserItem *)newUserItem originalUserItem:(SSJUserItem *)originalUserItem success:(void(^)())success failure:(void (^)(NSError *error))failure {
    
    RACSignal *sg_1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (SSJSetUserId(newUserItem.userId)) {
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"存储当前用户id发生错误"}]];
        }
        return nil;
    }];
    
    RACSignal *sg_2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJUserTableManager saveUserItem:newUserItem success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
    
    RACSignal *sg_3 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJUserTableManager saveUserItem:originalUserItem success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
    
    RACSignal *sg_4 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJLocalNotificationHelper cancelLocalNotificationWithUserId:originalUserItem.userId];
        [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithSuccess:^{
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
    
    [[[[sg_1 then:^RACSignal *{
        return sg_2;
    }] then:^RACSignal *{
        return sg_3;
    }] then:^RACSignal *{
        return sg_4;
    }] subscribeError:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(error);
            }
        });
    } completed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success();
            }
        });
    }];
}

@end
