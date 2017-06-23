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
#import "SSJUserDefaultDataCreater.h"
#import "SSJFundInfoSyncTable.h"
#import "SSJBooksTypeSyncTable.h"
#import "SSJUserBillSyncTable.h"
#import "SSJFinancingGradientColorItem.h"
#import "SSJLoginVerifyPhoneNumViewModel.h"

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
    if (![db executeUpdate:@"update bk_books_type set iparenttype = case when length(cbooksid) != length(cuserid) and cbooksid like cuserid || '%' then substr(cbooksid, length(cuserid) + 2, length(cbooksid) - length(cuserid) - 1) when cbooksid = cuserid then '0' end ,iversion = ? ,cwritedate = ? where iparenttype is null",@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
        if (error) {
            *error = [db lastError];
        }
    }
}

+ (void)updateCustomUserBillNeededForUserId:(NSString *)userId billTypeItems:(NSArray *)items inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *writedate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    for (SSJCustomCategoryItem *item in items) {
        if (![db intForQuery:@"select count(1) from bk_user_bill where cuserid = ? and cbillid = ? and cbooksid = ?",userId,item.ibillid,item.cbooksid]) {
            if (![db executeUpdate:@"insert into bk_user_bill values (?,?,1,?,?,1,0,?)",userId,item.ibillid,writedate,@(SSJSyncVersion()),item.cbooksid]) {
                if (error) {
                    *error = [db lastError];
                }
            }
        }
    }
}

+ (void)updateFundColorForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet *result = [db executeQuery:@"select cfundid ,iorder from bk_fund_info where (length(cstartcolor) = 0 or cstartcolor is null) and cparent <> 'root'"];
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSArray *colors = [SSJFinancingGradientColorItem defualtColors];
    
    while ([result next]) {
        NSString *fundid = [result stringForColumn:@"cfundid"];
        NSString *order = [result stringForColumn:@"iorder"] ?: @"";
        NSDictionary *dic = @{@"fundid":fundid,
                              @"order":order};
        [tempArr addObject:dic];
    };
    
    for (NSDictionary *dict in tempArr) {
        NSString *fundid = [dict objectForKey:@"fundid"];
        NSString *order = [dict objectForKey:@"order"];
        NSInteger index = [order integerValue];
        if (index > 1) {
            index --;
        }
        index = index - index / 7 * 7;
        SSJFinancingGradientColorItem *item = [colors objectAtIndex:index];
        if (![db executeUpdate:@"update bk_fund_info set cstartcolor = ? , cendcolor = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cfundid = ?",item.startColor,item.endColor,cwriteDate,@(SSJSyncVersion()),fundid]) {
            *error = [db lastError];
        }
    }

}

+ (void)updateTableWhenLoginWithViewModel:(SSJLoginVerifyPhoneNumViewModel *)viewModel completion:(void(^)())completion {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        //  merge登陆接口返回的收支类型、资金账户、账本
        [SSJBooksTypeSyncTable mergeRecords:viewModel.booksTypeArray forUserId:SSJUSERID() inDatabase:db error:nil];
        //  更新父类型为空的账本
        [self updateBooksParentIfNeededForUserId:SSJUSERID() inDatabase:db error:nil];
        [self mergeWhenLoginWithRecords:viewModel.userBillArray forUserId:SSJUSERID() inDatabase:db error:nil];
        [SSJFundInfoSyncTable mergeRecords:viewModel.fundInfoArray forUserId:SSJUSERID() inDatabase:db error:nil];
        [self updateCustomUserBillNeededForUserId:SSJUSERID() billTypeItems:viewModel.customCategoryArray inDatabase:db error:nil];
        
        //  更新排序字段为空的收支类型
        [self updateBillTypeOrderIfNeededForUserId:SSJUSERID() inDatabase:db error:nil];
        
        [self updateFundColorForUserId:SSJUSERID() inDatabase:db error:nil];
        
        if (completion) {
            SSJDispatchMainAsync(^{
                completion();
            });
        }
    }];
}

+ (BOOL)mergeWhenLoginWithRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    BOOL hasUpdated = NO;
    for (NSDictionary *recordInfo in records) {
        if ([recordInfo[@"cbillid"] isEqualToString:@"1072"] || [recordInfo[@"cbillid"] isEqualToString:@"2046"]) {
            hasUpdated = YES;
            break;
        }
    }
    // 首先判断本地有没有用户的数据
    if (![db intForQuery:@"select count(1) from bk_user_bill where cuserid = ?",userId]) {
        // 如果本地没有该用户数据,则首先把后端的数据插入表中
        for (NSDictionary *recordInfo in records) {
            NSString *sql = [NSString stringWithFormat:@"insert into bk_user_bill (cbillid, cuserid, istate, iorder, cwritedate, iversion, operatortype, cbooksid) values ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", recordInfo[@"cbillid"], recordInfo[@"cuserid"], recordInfo[@"istate"], recordInfo[@"iorder"], recordInfo[@"cwritedate"], recordInfo[@"iversion"], recordInfo[@"operatortype"],recordInfo[@"cbooksid"] ? : recordInfo[@"cuserid"]];
            if (![db executeUpdate:sql]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        }
        // 然后将所有cbooksid为null的账户类型改为日常账本
        if (![db executeUpdate:@"update bk_user_bill set cbooksid = ? where cuserid = ? and cbooksid is null",userId,userId]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        // 如果后端数据没有升级的话要对后端数据进行处理
        if (!hasUpdated) {
            NSString *sql1 = [NSString stringWithFormat:@"replace into bk_user_bill select ub.cuserid, ub.cbillid, ub.istate, '%@', '%@', 1, ub.iorder, bk.cbooksid from bk_user_bill ub , bk_books_type bk where ub.operatortype <> 2 and bk.cbooksid not like bk.cuserid || '%%' and ub.cbooksid = bk.cuserid and length(ub.cbillid) < 10  and bk.cuserid = '%@' and ub.cuserid = '%@'",writeDate,@(SSJSyncVersion()),userId,userId];
            // 然后将日常账本的记账类型拷进自定义账本
            if (![db executeUpdate:sql1]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
            
            // 将四个非日常账本的默认账本插入所有默认类型
            NSString *sql2 = [NSString stringWithFormat:@"replace into bk_user_bill select a.cuserid ,b.id , 1, '%@', '%@', 0, b.defaultorder, a.cbooksid from bk_books_type a, bk_bill_type b where a.iparenttype = b.ibookstype and a.cbooksid <> a.cuserid and length(b.ibookstype) = 1 and a.cbooksid like a.cuserid || '%%' and cuserid = '%@'",writeDate,@(SSJSyncVersion()),userId];
            if (![db executeUpdate:sql2]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
            
            FMResultSet *result = [db executeQuery:@"select id ,defaultorder ,ibookstype from bk_bill_type where length(ibookstype) > 1"];
            
            NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
            
            while ([result next]) {
                NSString *cbillid = [result stringForColumn:@"id"];
                NSString *defualtOrder = [result stringForColumn:@"defaultorder"];
                NSString *iparenttype = [result stringForColumn:@"ibookstype"];
                NSDictionary *dic = @{@"kBillIdKey":cbillid,
                                      @"kDefualtOrderKey":defualtOrder,
                                      @"kParentTypeKey":iparenttype};
                [tempArr addObject:dic];
            };
            
            for (NSDictionary *dict in tempArr) {
                NSString *cbillid = [dict objectForKey:@"kBillIdKey"];
                NSString *defualtOrder = [dict objectForKey:@"kDefualtOrderKey"];
                NSString *iparenttype = [dict objectForKey:@"kParentTypeKey"];
                NSArray *parentArr = [iparenttype componentsSeparatedByString:@","];
                for (NSString *parenttype in parentArr) {
                    if ([parenttype integerValue]) {
                        if (![db executeUpdate:@"replace into bk_user_bill select cuserid ,? , 1, ?, ?, 1, ?, cbooksid from bk_books_type where iparenttype = ? and operatortype <> 2 and cuserid = ?",cbillid,writeDate,@(SSJSyncVersion()),defualtOrder,parenttype,userId]) {
                            if (error) {
                                *error = [db lastError];
                            }
                            return NO;
                        }
                    }
                }
            }
        }
    }else{
        // 如果本地有数据
        if (hasUpdated) {
            // 如果后端数据库已经升级过了,则执行正常的合并操作
            [SSJUserBillSyncTable mergeRecords:records forUserId:userId inDatabase:db error:nil];
        }else{
            // 如果没有升级,则直接抛弃
        }
    }
    
    return YES;
}

@end
