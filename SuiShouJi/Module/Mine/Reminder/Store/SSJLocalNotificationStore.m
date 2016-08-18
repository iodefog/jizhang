//
//  SSJLocalNotificationStore.m
//  SuiShouJi
//
//  Created by ricky on 16/8/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLocalNotificationStore.h"

@implementation SSJLocalNotificationStore

+ (NSError *)saveReminderWithReminderItem:(SSJReminderItem *)item inDatabase:(FMDatabase *)db {
    if (!item.remindId.length) {
        item.remindId = SSJUUID();
    }
    
    NSString *userId = SSJUSERID();
    
    NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 判断是编辑还是新增
    if (![db intForQuery:@"select count(1) from bk_user_remind where cuserid = ? and cremindid = ?",userId,item.remindId]) {
        if (![db executeUpdate:@"update bk_user_remind set cremindname = ?, cmemo = ?, cstartdate  = ?, istate = ?, itype = ?, icycle = ?, iisend = ? , cwritedate = ?, operationtype = 1, iversion = ?",item.remindName,item.remindMemo,item.remindDate,item.remindState,item.remindType,item.remindCycle,item.remindAtTheEndOfMonth,cwriteDate,@(SSJSyncVersion())]) {
            return [db lastError];
        }
    }else{
        if (![db executeUpdate:@"insert into bk_user_remind (cremindid,cremindname,cmemo,cstartdate,istate,itype,icycle,iisend,cwritedate,operationtype,iversion) values (?,?,?,?,?,?,?,?,?,0,?)",item.remindId,item.remindName,item.remindMemo,item.remindDate,item.remindState,item.remindType,item.remindCycle,item.remindAtTheEndOfMonth,cwriteDate,@(SSJSyncVersion())]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (void)syncSaveReminderWithReminderItem:(SSJReminderItem *)item
                               Error:(NSError **)error {
    //  创建默认的资金帐户
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSError *tError = [self saveReminderWithReminderItem:item inDatabase:db];
        if (error) {
            *error = tError;
        }
    }];
}

+ (void)asyncsaveReminderWithReminderItem:(SSJReminderItem *)item
                                  Success:(void (^)(void))success
                                  failure:(void (^)(NSError *error))failure {
    //  创建默认的资金帐户
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *tError = [self saveReminderWithReminderItem:item inDatabase:db];
        if (tError) {
            if (failure) {
                failure(tError);
            }
        } else {
            if (success) {
                success();
            }
        }
    }];
}


@end
