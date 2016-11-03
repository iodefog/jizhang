//
//  SSJLoginHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/5/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoginHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJCustomCategoryItem.h"

@implementation SSJLoginHelper

+ (void)updateBillTypeOrderIfNeededForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    if (![db executeUpdate:@"update bk_user_bill set iorder = (select defaultorder from bk_bill_type where bk_user_bill.cbillid = bk_bill_type.id), cwritedate = ?, iversion = ?, operatortype = 1 where iorder is null and cuserid = ?", [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), userId]) {
        if (error) {
            *error = [db lastError];
        }
    }
}

+ (void)updateBooksParentIfNeededForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    // 更新默认账本的记账类型
    if (![db executeUpdate:@"update bk_books_type set iparenttype = case when length(cbooksid) != length(cuserid) and cbooksid like cuserid || '%' then substr(cbooksid, length(cuserid) + 2, length(cbooksid) - length(cuserid) - 1) when cbooksid = cuserid then '0' end ,iversion = ? ,cwritedate = ?",@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
        if (error) {
            *error = [db lastError];
        }
    }

}

+ (void)updateCustomUserBillNeededForUserId:(NSString *)userId billTypeItems:(NSArray *)items inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *writedate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    for (SSJCustomCategoryItem *item in items) {
        if (![db executeUpdate:@"insert into bk_user_bill values (?,?,1,?,?,1,0,?) where not exists select * from bk_user_bill where cuserid = ? and cbillid = ? and cbooksid = ?",userId,item.ibillid,writedate,@(SSJSyncVersion()),item.cbooksid,item.ibillid,userId,item.cbooksid,userId,item.ibillid,item.cbooksid]) {
            if (error) {
                *error = [db lastError];
            }
        }
    }
}

@end
