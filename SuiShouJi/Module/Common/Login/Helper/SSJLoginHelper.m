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

//+ (void)updateCustomUserBillNeededForUserId:(NSString *)userId billTypeItems:(NSArray *)items inDatabase:(FMDatabase *)db error:(NSError **)error {
//    NSString *writedate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//    for (SSJCustomCategoryItem *item in items) {
//        if (![db intForQuery:@"select count(1) from bk_user_bill where cuserid = ? and cbillid = ? and cbooksid = ?",userId,item.ibillid,item.cbooksid]) {
//            if (![db executeUpdate:@"insert into bk_user_bill values (?,?,1,?,?,1,0,?)",userId,item.ibillid,writedate,@(SSJSyncVersion()),item.cbooksid]) {
//                if (error) {
//                    *error = [db lastError];
//                }
//            }
//        }
//    }
//}

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

+ (void)updateTransferForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSMutableArray *chargeArr = [NSMutableArray arrayWithCapacity:0];
    
    FMResultSet *rs = [db executeQuery:@"select * from bk_user_charge where ibillid = ? and operatortype <> 2 and (ichargetype = ? or ichargetype = ?) and cuserid = ?",@(SSJSpecialBillIdBalanceRollIn),@(SSJChargeIdTypeTransfer),@(SSJChargeIdTypeNormal),userId];
    
    while ([rs next]) {
        NSMutableDictionary *userCharge = [NSMutableDictionary dictionaryWithCapacity:0];
        [userCharge setObject:[rs stringForColumn:@"ifunsid"] ? : @"" forKey:@"ifunsid"];
        [userCharge setObject:[rs stringForColumn:@"cwritedate"] ? : @"" forKey:@"cwritedate"];
        [userCharge setObject:[rs stringForColumn:@"ichargeid"] ? : @"" forKey:@"ichargeid"];
        [userCharge setObject:[rs stringForColumn:@"cuserid"] ? : @"" forKey:@"cuserid"];
        [userCharge setObject:[rs stringForColumn:@"ibillid"] ? : @"" forKey:@"ibillid"];
        [userCharge setObject:[rs stringForColumn:@"imoney"] ? : @"" forKey:@"imoney"];
        [userCharge setObject:[rs stringForColumn:@"cbilldate"] ? : @"" forKey:@"cbilldate"];
        [userCharge setObject:[rs stringForColumn:@"cmemo"] ? : @"" forKey:@"cmemo"];
        [chargeArr addObject:userCharge];
    }
    
    [rs close];
    
    for (NSMutableDictionary *userCharge in chargeArr) {
        NSString *writeDateStr = [userCharge objectForKey:@"cwritedate"];
        NSString *fundId = [userCharge objectForKey:@"ifunsid"];
        NSString *chargeid = [userCharge objectForKey:@"ichargeid"];
        NSString *userid = [userCharge objectForKey:@"cuserid"];
        NSString *money = [userCharge objectForKey:@"imoney"];
        NSString *billDate = [userCharge objectForKey:@"cbilldate"];
        NSString *memo = [userCharge objectForKey:@"cmemo"];
        NSDate *writeDate = [NSDate dateWithString:writeDateStr formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSDate *startDate = [writeDate dateBySubtractingSeconds:1];
        NSDate *endDate = [writeDate dateByAddingSeconds:1];
        NSString *otherChargeId = [db stringForQuery:@"select ichargeid from bk_user_charge where cwritedate between ? and ? and ibillid = ? and imoney = ? and cuserid = ? and cbilldate = ? limit 1",[startDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[endDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSpecialBillIdBalanceRollOut),money,userid,billDate];
        if (otherChargeId.length) {
            NSString *otherFundid = [db stringForQuery:@"select ifunsid from bk_user_charge where ichargeid = ?",otherChargeId];
            NSString *cycleId = SSJUUID();
            NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSMutableDictionary *transferCycle = [NSMutableDictionary dictionaryWithCapacity:0];
            [transferCycle setObject:cycleId forKey:@"icycleid"];
            [transferCycle setObject:userid forKey:@"cuserid"];
            [transferCycle setObject:fundId forKey:@"ctransferinaccountid"];
            [transferCycle setObject:otherFundid forKey:@"ctransferoutaccountid"];
            [transferCycle setObject:money forKey:@"imoney"];
            [transferCycle setObject:memo forKey:@"cmemo"];
            [transferCycle setObject:@(SSJCyclePeriodTypeOnce) forKey:@"icycletype"];
            [transferCycle setObject:billDate forKey:@"cbegindate"];
            [transferCycle setObject:@(1) forKey:@"istate"];
            [transferCycle setObject:writeDate forKey:@"cwritedate"];
            [transferCycle setObject:@(SSJSyncVersion()) forKey:@"iversion"];
            [transferCycle setObject:@(1) forKey:@"operatortype"];
            [transferCycle setObject:writeDate forKey:@"clientadddate"];
            [db executeUpdate:@"insert into bk_transfer_cycle (icycleid, cuserid, ctransferinaccountid, ctransferoutaccountid, imoney, cmemo, icycletype, cbegindate, istate, cwritedate, iversion, operatortype, clientadddate) values (:icycleid, :cuserid, :ctransferinaccountid, :ctransferoutaccountid, :imoney, :cmemo, :icycletype, :cbegindate, :istate, :cwritedate, :iversion, :operatortype, :clientadddate)" withParameterDictionary:transferCycle];
            
            [db executeUpdate:@"update bk_user_charge set ichargetype = ?, cid = ?, cwritedate = ?, iversion = ?, operatortype = ? where ichargeid = ? and cuserid = ?",@(SSJChargeIdTypeCyclicTransfer),cycleId,writeDate,@(SSJSyncVersion()),@(1),otherChargeId,userid];
            
            [db executeUpdate:@"update bk_user_charge set ichargetype = ?, cid = ?, cwritedate = ?, iversion = ?, operatortype = ? where ichargeid = ? and cuserid = ?",@(SSJChargeIdTypeCyclicTransfer),cycleId,writeDate,@(SSJSyncVersion()),@(1),chargeid,userid];
        } else {
            [db executeUpdate:@"delete from bk_user_charge where ichargeid = ?",chargeid];
        }
    }

}

+ (void)updateTableWhenLoginWithViewModel:(SSJLoginVerifyPhoneNumViewModel *)viewModel completion:(void(^)())completion {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        //  merge登陆接口返回的收支类型、资金账户、账本
        [[SSJBooksTypeSyncTable table] mergeRecords:viewModel.booksTypeArray forUserId:SSJUSERID() inDatabase:db error:nil];
        //  更新父类型为空的账本
        [self updateBooksParentIfNeededForUserId:SSJUSERID() inDatabase:db error:nil];
        [[SSJFundInfoSyncTable table] mergeRecords:viewModel.fundInfoArray forUserId:SSJUSERID() inDatabase:db error:nil];
        
        if (viewModel.userBillTypeArray.count) {
            [[SSJUserBillTypeSyncTable table] mergeRecords:viewModel.userBillTypeArray forUserId:SSJUSERID() inDatabase:db error:nil];
        } else {
            // 如果用户的收支类别没有迁移到新表中，后端会反回老结构的收支类别数据，客户端需要把数据格式处理成新表的结构，写入新表中
            NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSMutableArray *userBillTypeArray = [NSMutableArray array];
            for (NSDictionary *bookBillRecord in viewModel.bookBillsArray) {
                NSString *ID = [NSString stringWithFormat:@"%@_%@", bookBillRecord[@"cbillid"], bookBillRecord[@"cbooksid"]];
                NSDictionary *userBillRecord = viewModel.userBillInfo[ID];
                SSJBillTypeModel *billTypeModel = SSJBillTypeModel(userBillRecord[@"cbillid"]);
                // 如果收支类别在老表中是未开启的，迁移到新表后就当作删除
                id operatortype = [userBillRecord[@"istate"] integerValue] == 0 ? @2 : userBillRecord[@"operatortype"];
                // 如果本地文件中没有对应的类别，说明是自定义类别，从服务端返回的类别中找
                if (billTypeModel) {
                    [userBillTypeArray addObject:@{@"cbillid":userBillRecord[@"cbillid"],
                                                   @"cuserid":SSJUSERID(),
                                                   @"cbooksid":userBillRecord[@"cbooksid"],
                                                   @"itype":@(billTypeModel.expended),
                                                   @"cname":billTypeModel.name,
                                                   @"ccolor":billTypeModel.color,
                                                   @"cicoin":billTypeModel.icon,
                                                   @"iorder":userBillRecord[@"iorder"],
                                                   @"cwritedate":writeDate,
                                                   @"operatortype":operatortype,
                                                   @"iversion":@(SSJSyncVersion())}];
                } else if (userBillRecord) {
                    NSDictionary *billTypeInfo = viewModel.billTypeInfo[bookBillRecord[@"cbillid"]];
                    [userBillTypeArray addObject:@{@"cbillid":userBillRecord[@"cbillid"],
                                                   @"cuserid":SSJUSERID(),
                                                   @"cbooksid":userBillRecord[@"cbooksid"],
                                                   @"itype":billTypeInfo[@"itype"],
                                                   @"cname":billTypeInfo[@"cname"],
                                                   @"ccolor":billTypeInfo[@"ccolor"],
                                                   @"cicoin":billTypeInfo[@"ccoin"],
                                                   @"iorder":userBillRecord[@"iorder"],
                                                   @"cwritedate":writeDate,
                                                   @"operatortype":operatortype,
                                                   @"iversion":@(SSJSyncVersion())}];
                }
            }
            
            [[SSJUserBillTypeSyncTable table] mergeRecords:userBillTypeArray forUserId:SSJUSERID() inDatabase:db error:nil];
        }
        
        // ??? 啥玩意 懵逼
//        [self updateCustomUserBillNeededForUserId:SSJUSERID() billTypeItems:viewModel.customCategoryArray inDatabase:db error:nil];
        
        [self updateTransferForUserId:SSJUSERID() inDatabase:db error:nil];
        
        [self updateFundColorForUserId:SSJUSERID() inDatabase:db error:nil];
        
        if (completion) {
            SSJDispatchMainAsync(^{
                completion();
            });
        }
    }];
}

@end
