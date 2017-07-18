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
#import "SSJLoginVerifyPhoneViewController+SSJLoginCategory.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJBookkeepingTreeHelper.h"

@implementation SSJDataClearHelper

+ (void)clearLocalDataWithSuccess:(void(^)())success
                          failure:(void (^)(NSError *error))failure{
    
    NSString *userId = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        if ([db executeUpdate:@"delete from bk_member_charge where ichargeid in (select ichargeid from bk_user_charge where cuserid = ?)", userId]
            && [db executeUpdate:@"delete from bk_member where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_user_budget where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_user_charge where cuserid = ? or cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ?)", userId, userId]
            && [db executeUpdate:@"delete from bk_charge_period_config where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_fund_info where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_user_bill_type where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_books_type where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_sync where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_credit_repayment where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_loan where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_user_credit where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_transfer_cycle where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_user_remind where cuserid = ?", userId]
            && [db executeUpdate:@"delete from bk_share_books where cbooksid in (select cbooksid from bk_share_books_friends_mark where cuserid = ?)", userId]
            && [db executeUpdate:@"delete from bk_share_books_member where cmemberid || cbooksid in (select cfriendid || cbooksid from bk_share_books_friends_mark where cuserid = ?)", userId]
            && [db executeUpdate:@"delete from bk_share_books_friends_mark where cuserid = ?", userId]) {
            
            [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:^(SSJDataSynchronizeType type) {
                if (type == SSJDataSynchronizeTypeData) {
                    if (success) {
                        success();
                    }
                }
            } failure:^(SSJDataSynchronizeType type, NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        } else {
            *rollback = YES;
            SSJDispatchMainAsync(^{
                if (failure) {
                    failure([db lastError]);
                }
            });
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
        newuserItem.currentBooksId = newuserItem.userId;
        
        // 老用户id没过注册过，说明没有登录，为登陆情况下数据格式化不请求接口
        if (SSJIsUserLogined()) {
            
            SSJClearUserDataService *service = [[SSJClearUserDataService alloc]initWithDelegate:nil];
            [service clearUserDataWithOriginalUserid:originalUserid newUserid:newUserId Success:^{
                
                if ([service.returnCode isEqualToString:@"-5555"]) {
                    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"数据已格式化成功，请重新登录！" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                        [SSJLoginVerifyPhoneViewController reloginIfNeeded];
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
        [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithUserId:SSJUSERID() success:^{
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

+ (void)uploadAllUserDataWithSuccess:(void(^)(NSString *syncTime))success
                             failure:(void (^)(NSError *error))failure {
    NSString *userId = SSJUSERID();
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
            if ([db executeUpdate:@"delete from bk_sync where cuserid = ?", userId]) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[db lastError]];
            }
        }];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:^(SSJDataSynchronizeType type) {
                if (type == SSJDataSynchronizeTypeData) {
                    [subscriber sendCompleted];
                }
            } failure:^(SSJDataSynchronizeType type, NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
                NSString *syncTime = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm"];
                if ([db executeUpdate:@"update bk_user set clastsynctime = ? where cuserid = ?", syncTime, userId]) {
                    [subscriber sendNext:syncTime];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:[db lastError]];
                }
            }];
            return nil;
        }];
    }] subscribeNext:^(NSString *time) {
        if (success) {
            SSJDispatchMainAsync(^{
                success(time);
            });
        }
    } error:^(NSError *error) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure(error);
            });
        }
    }];
}

+ (void)caculateCacheDataSizeWithSuccess:(void(^)(int64_t size))success
                                 failure:(void (^)(NSError *error))failure {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int64_t size = [SSJBookkeepingTreeHelper caculateCacheSize];
        size += [UIImage ssj_memoCache].totalCost;
        size += [[SDImageCache sharedImageCache] getSize];
        SSJDispatchMainAsync(^{
            if (success) {
                success(size);
            }
        });
    });
}

+ (void)clearLocalDataCacheWithSuccess:(void(^)())success
                               failure:(void (^)(NSError *error))failure {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SSJBookkeepingTreeHelper clearCache];
        [[UIImage ssj_memoCache] removeAllObjects];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            SSJDispatchMainAsync(^{
                if (success) {
                    success();
                }
            });
        }];
    });
}

@end
