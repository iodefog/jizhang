//
//  SSJLocalNotificationStore.m
//  SuiShouJi
//
//  Created by ricky on 16/8/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLocalNotificationStore.h"
#import "SSJLocalNotificationHelper.h"

@implementation SSJLocalNotificationStore

+ (void)queryForreminderListForUserId:(NSString *)userId
                          WithSuccess:(void(^)(NSArray<SSJReminderItem *> *result))success
                               failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if (!userId.length) {
            SSJPRINT(@"userid不能为空");
            return;
        }
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        FMResultSet * resultSet = [db executeQuery:@"select * from bk_user_remind where cuserid = ? and operatortype <> 2",userId];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([resultSet next]) {
            SSJReminderItem *item = [[SSJReminderItem alloc]init];
            item.remindId = [resultSet stringForColumn:@"cremindid"];
            item.remindName = [resultSet stringForColumn:@"cremindname"];
            item.remindMemo = [resultSet stringForColumn:@"cmemo"];
            if (item.remindMemo.length) {
                item.rowHeight = 90;
            } else {
                item.rowHeight = 70;
            }
            item.remindCycle = [resultSet intForColumn:@"icycle"];
            item.remindType = [resultSet intForColumn:@"itype"];
            NSString *dateStr = [resultSet stringForColumn:@"cstartdate"];
            item.remindDate = [NSDate dateWithString:dateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
            item.remindState = [resultSet boolForColumn:@"istate"];
            item.remindAtTheEndOfMonth = [resultSet intForColumn:@"iisend"];
            if (item.remindType == SSJReminderTypeBorrowing){
                NSString *minmumDate = [db stringForQuery:@"select cborrowdate from bk_loan where cremindid = ? and cuserid = ?",item.remindId,userId];
                item.minimumDate = [NSDate dateWithString:minmumDate formatString:@"yyyy-MM-dd HH:mm:ss"];
            }
            [tempArr addObject:item];
        }
        [resultSet close];
        for (SSJReminderItem *item in tempArr) {
            if (item.remindType == SSJReminderTypeBorrowing) {
                item.fundId = [db stringForQuery:@"select loanid from bk_loan where cremindid = ?",item.remindId];
                item.borrowtarget = [db stringForQuery:@"select lender from bk_loan where cremindid = ?",item.remindId];
                item.borrowtOrLend = ![db intForQuery:@"select itype from bk_loan where cremindid = ?",item.remindId];
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArr);
            });
        }
    }];
}

+ (NSError *)saveReminderWithReminderItem:(SSJReminderItem *)item
                               inDatabase:(FMDatabase *)db {
    if (!item.remindId.length) {
        item.remindId = SSJUUID();
    }
    
    NSString *userId = SSJUSERID();
    
    NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:item];
    
    // 判断是编辑还是新增
    if ([db intForQuery:@"select count(1) from bk_user_remind where cuserid = ? and cremindid = ?",userId,item.remindId]) {
        if (![db executeUpdate:@"update bk_user_remind set cremindname = ?, cmemo = ?, cstartdate  = ?, istate = ?, itype = ?, icycle = ?, iisend = ? , cwritedate = ?, operatortype = 1, iversion = ? where cuserid = ? and cremindid = ?",item.remindName,item.remindMemo,[item.remindDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"], @(item.remindState),@(item.remindType),@(item.remindCycle),@(item.remindAtTheEndOfMonth),cwriteDate,@(SSJSyncVersion()),userId,item.remindId]) {
            return [db lastError];
        }
        [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:item];
    }else{
        if (![db executeUpdate:@"insert into bk_user_remind (cremindid,cremindname,cmemo,cstartdate,istate,itype,icycle,iisend,cwritedate,operatortype,iversion,cuserid) values (?,?,?,?,?,?,?,?,?,0,?,?)",item.remindId,item.remindName,item.remindMemo,[item.remindDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"],@(item.remindState),@(item.remindType),@(item.remindCycle),@(item.remindAtTheEndOfMonth),cwriteDate,@(SSJSyncVersion()),userId]) {
            return [db lastError];
        }
        [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:item];
    }
    
    return nil;
}

+ (void)syncSaveReminderWithReminderItem:(SSJReminderItem *)item
                               Error:(NSError **)error {
    //  保存提醒
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSError *tError = [self saveReminderWithReminderItem:item inDatabase:db];
        SSJDispatch_main_async_safe(^{
            if (error) {
                *error = tError;
            }
        });
    }];
}

+ (void)asyncsaveReminderWithReminderItem:(SSJReminderItem *)item
                                  Success:(void (^)(SSJReminderItem *))success
                                  failure:(void (^)(NSError *error))failure {
    //  保存提醒
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *tError = [self saveReminderWithReminderItem:item inDatabase:db];
        if (tError) {
            SSJDispatch_main_async_safe(^{
                if (failure) {
                    failure(tError);
                }
            });
        } else {
            SSJDispatch_main_async_safe(^{
                if (success) {
                    success(item);
                }
            });
        }
    }];
}

+ (SSJReminderItem *)queryReminderItemForID:(NSString *)remindId {
    SSJReminderItem *item = [[SSJReminderItem alloc] init];
    NSString *userId = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_user_remind where cremindid = ?",remindId];
        [resultSet next];
        item.remindId = [resultSet stringForColumn:@"cremindid"];
        item.remindName = [resultSet stringForColumn:@"cremindname"];
        item.remindMemo = [resultSet stringForColumn:@"cmemo"];
        item.remindCycle = [resultSet intForColumn:@"icycle"];
        item.remindType = [resultSet intForColumn:@"itype"];
        item.remindAtTheEndOfMonth = [resultSet boolForColumn:@"iisend"];
        NSDate *remindStartDate = [NSDate dateWithString:[resultSet stringForColumn:@"CSTARTDATE"] formatString:@"yyyy-MM-dd HH:mm:ss"];
        item.remindDate = [SSJLocalNotificationHelper calculateNexRemindDateWithStartDate:remindStartDate remindCycle:item.remindCycle remindAtEndOfMonth:item.remindAtTheEndOfMonth];
        item.remindState = [resultSet boolForColumn:@"istate"];
        if (item.remindType == SSJReminderTypeBorrowing){
            NSString *minmumDate = [db stringForQuery:@"select cborrowdate from bk_loan where cremindid = ? and cuserid = ?",item.remindId,userId];
            item.minimumDate = [NSDate dateWithString:minmumDate formatString:@"yyyy-MM-dd HH:mm:ss"];
        }
        [resultSet close];
    }];
    return item;
}

+ (BOOL)deleteReminderWithItem:(SSJReminderItem *)remindItem error:(NSError **)error{
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *cwritedate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        success = [db executeUpdate:@"update bk_user_remind set operatortype = 2 , cwritedate = ? , iversion = ? where cremindid = ? and cuserid = ?",cwritedate,@(SSJSyncVersion()),remindItem.remindId,userId] && [db executeUpdate:@"update bk_loan set cremindid = '' , cwritedate = ? , iversion = ? where cremindid = ? and cuserid = ?",cwritedate,@(SSJSyncVersion()),remindItem.remindId,userId] && [db executeUpdate:@"update bk_user_credit set cremindid = '' , cwritedate = ? , iversion = ? where cremindid = ? and cuserid = ?",cwritedate,@(SSJSyncVersion()),remindItem.remindId,userId];
        if (success) {
            [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:remindItem];
        }
    }];
    return success;
}


+ (BOOL)deleteWishReminderWithItem:(SSJReminderItem *)remindItem error:(NSError **)error {
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *cwritedate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        success = [db executeUpdate:@"update bk_user_remind set operatortype = 2 , cwritedate = ? , iversion = ? where cremindid = ? and cuserid = ?",cwritedate,@(SSJSyncVersion()),remindItem.remindId,userId] && [db executeUpdate:@"update bk_wish set remindid = '' , cwritedate = ? , iversion = ? where remindid = ? and cuserid = ?",cwritedate,@(SSJSyncVersion()),remindItem.remindId,userId];
        if (success) {
            [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:remindItem];
        }
    }];
    return success;
}

@end
