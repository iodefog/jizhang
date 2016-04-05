
//
//  SSJPersonalDetailHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPersonalDetailHelper.h"
#import "SSJDatabaseQueue.h"

@interface SSJPersonalDetailHelper()

@end

@implementation SSJPersonalDetailHelper
+ (void)queryUserDetailWithsuccess:(void (^)(SSJPersonalDetailItem *data))success
                           failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *result = [db executeQuery:@"select * from bk_user where cuserid = ?",userid];
        if (!result) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        SSJPersonalDetailItem *item = [self personalDetailItemWithResultSet:result inDatabase:db];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(item);
            });
        }
    }];
}

+ (SSJPersonalDetailItem *)personalDetailItemWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJPersonalDetailItem *item = [[SSJPersonalDetailItem alloc] init];
    item.iconUrl = [set stringForColumn:@"CICONS"];
    item.nickName = [set stringForColumn:@"CNICKID"];
    item.signature = [set stringForColumn:@"USERSIGNAGUTURE"];
    item.mobileNo = [set stringForColumn:@"CMOBILENO"];
    return item;
}

@end
