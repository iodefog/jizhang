//
//  SSJLoginHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/5/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoginHelper.h"
#import "SSJDatabaseQueue.h"

@implementation SSJLoginHelper

+ (void)updateBillTypeOrderIfNeededForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    if (![db executeUpdate:@"update bk_user_bill set iorder = (select defaultorder from bk_bill_type where bk_user_bill.cbillid = bk_bill_type.id), cwritedate = ?, iversion = ?, operatortype = 1 where iorder is null and cuserid = ?", [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), userId]) {
        *error = [db lastError];
    }
}

+ (void)updateBooksParentIfNeededForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    // 更新默认账本的记账类型
    if (![db executeUpdate:@"update bk_books_type set iparenttype = case when length(cbooksid) != length(cuserid) and cbooksid like cuserid || '%' then substr(cbooksid, length(cuserid) + 2, length(cbooksid) - length(cuserid) - 1) case when cbooksid = cuserid then '0' end ,iversion = ? ,cwritedate = ?",@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
        *error = [db lastError];
    }
    
    // 更新记账类型为空的账本
    if (![db executeUpdate:@"update bk_books_type set iparent = 0 where iparent is null"]) {
        *error = [db lastError];
    }
}

@end
