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
#import "SSJUserBillTypeSyncTable.h"
#import "SSJFinancingGradientColorItem.h"
#import "SSJLoginVerifyPhoneNumViewModel.h"
#import "SSJBillTypeManager.h"

@implementation SSJLoginHelper

+ (void)updateBooksParentIfNeededForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    // 更新默认账本的记账类型
    if (![db executeUpdate:@"update bk_books_type set iparenttype = case when length(cbooksid) != length(cuserid) and cbooksid like cuserid || '%' then substr(cbooksid, length(cuserid) + 2, length(cbooksid) - length(cuserid) - 1) when cbooksid = cuserid then '0' end ,iversion = ? ,cwritedate = ? where iparenttype is null",@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
        if (error) {
            *error = [db lastError];
        }
    }
}

+ (void)updateCustomUserBillNeededForUserId:(NSString *)userId billTypeItems:(NSArray *)items inDatabase:(FMDatabase *)db error:(NSError **)error {
//    NSString *writedate = [[NSDate date] :@"yyyy-MM-dd HH:mm:ss.SSS"];
//    for (SSJCustomCategoryItem *item in items) {
//        if (![db intForQuery:@"select count(1) from bk_user_bill_type where cuserid = ? and cbillid = ? and cbooksid = ?",userId,item.ibillid,item.cbooksid]) {
//            
//            NSDictionary *recordInfo = @{};
//            if (![db executeUpdate:@"insert into bk_user_bill_type (cbillid, cuserid, cbooksid, itype, cname, ccolor, cicoin, cwritedate, operatortype, iversion) values (:cbillid, :cuserid, :cbooksid, :itype, :cname, :ccolor, :cicoin, :cwritedate, :operatortype, :iversion)", userId, item.ibillid, writedate, @(SSJSyncVersion()), item.cbooksid]) {
//                if (error) {
//                    *error = [db lastError];
//                }
//            }
//        }
//    }
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
        [SSJFundInfoSyncTable mergeRecords:viewModel.fundInfoArray forUserId:SSJUSERID() inDatabase:db error:nil];
        if (viewModel.userBillTypeArray.count) {
            [SSJUserBillTypeSyncTable mergeRecords:viewModel.userBillTypeArray forUserId:SSJUSERID() inDatabase:db error:nil];
        } else {
            // 如果用户的收支类别没有迁移到新表中，后端会反回老结构的收支类别数据，客户端需要把数据格式处理成新表的结构，写入新表中
            NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSMutableArray *userBillTypeArray = [NSMutableArray array];
            for (NSDictionary *bookBillRecord in viewModel.bookBillsArray) {
                for (NSDictionary *userBillRecord in viewModel.userBillArray) {
                    if ([bookBillRecord[@"cbillid"] isEqualToString:userBillRecord[@"cbillid"]]
                        && [bookBillRecord[@"booksid"] isEqualToString:userBillRecord[@"cbooksid"]]) {
                        [userBillTypeArray addObject:@{@"cbillid":userBillRecord[@"cbillid"],
                                                       @"cuserid":SSJUSERID(),
                                                       @"cbooksid":userBillRecord[@"cbooksid"],
                                                       @"itype":@(SSJBillTypeModel(userBillRecord[@"cbillid"]).expended),
                                                       @"cname":SSJBillTypeModel(userBillRecord[@"cbillid"]).name,
                                                       @"ccolor":SSJBillTypeModel(userBillRecord[@"cbillid"]).color,
                                                       @"cicoin":SSJBillTypeModel(userBillRecord[@"cbillid"]).icon,
                                                       @"iorder":userBillRecord[@"iorder"],
                                                       @"cwritedate":writeDate,
                                                       @"operatortype":userBillRecord[@"operatortype"],
                                                       @"iversion":@(SSJSyncVersion())}];
                        break;
                    }
                }
            }
            
            [SSJUserBillTypeSyncTable mergeRecords:userBillTypeArray forUserId:SSJUSERID() inDatabase:db error:nil];
        }
        
#warning 懵逼
        // ??? 啥玩意 懵逼
        [self updateCustomUserBillNeededForUserId:SSJUSERID() billTypeItems:viewModel.customCategoryArray inDatabase:db error:nil];
        
        [self updateFundColorForUserId:SSJUSERID() inDatabase:db error:nil];
        
        if (completion) {
            SSJDispatchMainAsync(^{
                completion();
            });
        }
    }];
}

@end
