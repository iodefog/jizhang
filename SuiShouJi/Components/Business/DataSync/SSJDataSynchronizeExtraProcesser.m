//
//  SSJDataSynchronizeExtraProcesser.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/31.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDataSynchronizeExtraProcesser.h"
#import "SSJDatabaseQueue.h"
#import "SSJRegularManager.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJLocalNotificationStore.h"
#import "SSJUserDefaultBillTypesCreater.h"
#import "SSJFinancingGradientColorItem.h"
#import "SSJLoanChargeModel.h"
#import "SSJDatabaseVersion18.h"

@implementation SSJDataSynchronizeExtraProcesser

+ (void)extraProcessWithUserID:(NSString *)userID data:(NSDictionary *)data {
    [self switchAnotherBookIfNeeded:userID];
    
    // 合并数据完成后补充周期数据；即使补充失败，也不影响同步，在其他时机可以再次补充
    [SSJRegularManager supplementCycleRecordsForUserId:userID];
    
    [self supplementMemberCharges:userID];
    
    [self resetLocalNotification:userID];
    
    [self updateBookIcon:userID];
    
    [self updateChargeDetailDate];
    
    [self updateFundGradientColor];
    
    [self deleteDataOfShareBooksQuitted:userID];
    
    [self supplementBillTypesOfShareBooks:userID];
    
    [self upgradeOldTransferCharges:userID];
    
    [self upgradeLoanCharges:data[@"bk_user_charge"]];
    
    [self removeDuplicateTransferCharges:userID];
}

/**
 如果用户当前账本已删除或者已退出，就切换成日常账本
 */
+ (void)switchAnotherBookIfNeeded:(NSString *)userID {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *currentBooksid = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?", userID];
        
        if ([db boolForQuery:@"select count(1) from bk_share_books where cbooksid = ?",currentBooksid]) {
            NSInteger currentBooksStatus = [db intForQuery:@"select istate from bk_share_books_member where cbooksid = ? and cmemberid = ?", currentBooksid, userID];
            if (currentBooksStatus != SSJShareBooksMemberStateNormal) {
                [db executeUpdate:@"update bk_user set ccurrentbooksid = ?", userID];
                SSJDispatchMainSync(^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:NULL];
                });
            }
        } else {
            if ([db intForQuery:@"select operatortype from bk_books_type where cuserid = ? and cbooksid = ?", userID, currentBooksid] == 2) {
                [db executeUpdate:@"update bk_user set ccurrentbooksid = ?", userID];
                SSJDispatchMainAsync(^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
                });
            }
        }
    }];
}

/**
 用户流水表中存在，但是成员流水表中不存在的流水插入到成员流水表中，默认就是用户自己的
 */
+ (void)supplementMemberCharges:(NSString *)userID {
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL success = [db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) select a.ichargeid, ?, a.imoney, ?, ?, 0 from bk_user_charge as a left join bk_member_charge as b on a.ichargeid = b.ichargeid where b.ichargeid is null and a.operatortype <> 2 and a.cuserid = ?", [NSString stringWithFormat:@"%@-0", userID], @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], userID];
        if (!success) {
            *rollback = YES;
        }
    }];
}

/**
 根据用户的提醒表中的记录注册本地通知
 */
+ (void)resetLocalNotification:(NSString *)userID {
    [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJReminderNotificationKey];
    [SSJLocalNotificationStore queryForreminderListForUserId:userID WithSuccess:^(NSArray<SSJReminderItem *> *result) {
        for (SSJReminderItem *item in result) {
            [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:item];
        }
    } failure:^(NSError *error) {
        SSJPRINT(@"警告：同步后注册本地通知失败 error:%@", [error localizedDescription]);
    }];
}

/**
 因为老版本没有同步账本图标，老版本同步过来的数据图表为空，所以这里把图标加上
 */
+ (void)updateBookIcon:(NSString *)userID {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *booksID1 = userID;
        NSString *booksID2 = [NSString stringWithFormat:@"%@-1", userID];
        NSString *booksID3 = [NSString stringWithFormat:@"%@-2", userID];
        NSString *booksID4 = [NSString stringWithFormat:@"%@-3", userID];
        NSString *booksID5 = [NSString stringWithFormat:@"%@-4", userID];
        
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_moren' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID1, userID];
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_shengyi' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID2, userID];
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_jiehun' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID3, userID];
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_zhuangxiu' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID4, userID];
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_lvxing' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID5, userID];
        
        NSString *sqlStr = [NSString stringWithFormat:@"update bk_books_type set cicoin = 'bk_moren' where cbooksid not in ('%@', '%@', '%@', '%@', '%@') and cuserid = '%@' and (length(cicoin) == 0 or cicoin is null)", booksID1, booksID2, booksID3, booksID4, booksID5, userID];
        [db executeUpdate:sqlStr];
    }];
}

/**
 将没有新加字段cdetaildate的流水补上
 */
+ (void)updateChargeDetailDate {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"update bk_user_charge set cdetaildate = '00:00' where ichargetype = ?", @(SSJChargeIdTypeCircleConfig)];
        
        [db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(clientadddate,12,5) from bk_user_charge where length(cdetaildate) = 0 or cdetaildate is null) where length(clientadddate) > 0 and ichargetype <> ? and (length(cdetaildate) = 0 or cdetaildate is null)", @(SSJChargeIdTypeCircleConfig)];
        
        [db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(cwritedate,12,5) from bk_user_charge where length(cdetaildate) = 0 or cdetaildate is null) where length(cdetaildate) = 0 or cdetaildate is null"];
    }];
}

/**
 将没有渐变色的数据改成渐变色
 */
+ (void)updateFundGradientColor {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select cfundid ,iorder from bk_fund_info where (length(cstartcolor) = 0 or cstartcolor is null) and cparent <> 'root' and operatortype <> 2"];
        
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
            [db executeUpdate:@"update bk_fund_info set cstartcolor = ? , cendcolor = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cfundid = ?",item.startColor,item.endColor,cwriteDate,@(SSJSyncVersion()),fundid];
        }
    }];
}

/**
  删除已经退出的账本中的share_books,share_books_friends_mark
 */
+ (void)deleteDataOfShareBooksQuitted:(NSString *)userID {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from bk_share_books where cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ? and istate != ?)", userID, @(SSJShareBooksMemberStateNormal)];
        [db executeUpdate:@"delete from bk_share_books_friends_mark where cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ? and istate != ?)", userID, @(SSJShareBooksMemberStateNormal)];
    }];
}

/**
 将一个收支类别的账本补充一套收支类别
 */
+ (void)supplementBillTypesOfShareBooks:(NSString *)userID {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSMutableArray *booksResult = [NSMutableArray arrayWithCapacity:0];
        
        FMResultSet *shareBooksResult = [db executeQuery:@"select sb.iparenttype ,ub.cbooksid ,ub.cuserid , count(ub.cbillid) from bk_share_books sb, bk_share_books_member sbm left join bk_user_bill_type ub on sbm.cbooksid = ub.cbooksid and ub.cuserid = sbm.cmemberid where length(ub.cbillid) < 10 and ub.cuserid = ? and sb.cbooksid = ub.cbooksid group by ub.cbooksid, ub.cuserid having count(ub.cbillid) = 0", userID];
        
        while ([shareBooksResult next]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            NSString *booksId = [shareBooksResult stringForColumn:@"cbooksid"];
            NSInteger parentType = [shareBooksResult intForColumn:@"iparenttype"];
            [dic setObject:booksId forKey:@"cbooksid"];
            [dic setObject:@(parentType) forKey:@"iparenttype"];
            [booksResult addObject:dic];
        }
        
        [shareBooksResult close];
        
        FMResultSet *normalBooksResult = [db executeQuery:@"select bt.iparenttype, ub.cbooksid, ub.cuserid, count(ub.cbillid) from bk_books_type bt left join bk_user_bill_type ub on bt.cbooksid = ub.cbooksid and ub.cuserid = bt.cuserid where length(ub.cbillid) < 10 and ub.cuserid = ? group by ub.cbooksid, ub.cuserid having count(ub.cbillid) = 0", userID];
        
        while ([normalBooksResult next]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            NSString *booksId = [normalBooksResult stringForColumn:@"cbooksid"];
            NSInteger parentType = [normalBooksResult intForColumn:@"iparenttype"];
            [dic setObject:booksId forKey:@"cbooksid"];
            [dic setObject:@(parentType) forKey:@"iparenttype"];
            [booksResult addObject:dic];
        }
        
        [shareBooksResult close];
        
        for (NSDictionary *dic in booksResult) {
            NSString *booksId = [dic objectForKey:@"cbooksid"];
            NSInteger parentType = [[dic objectForKey:@"iparenttype"] integerValue];
            [SSJUserDefaultBillTypesCreater createDefaultDataTypeForUserId:userID booksId:booksId booksType:parentType inDatabase:db error:nil];
        }
    }];
}

/**
 将以前的转账包括安卓chargetype为4的转账转移到周期转账表里
 */
+ (void)upgradeOldTransferCharges:(NSString *)userID {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSMutableArray *chargeArr = [NSMutableArray arrayWithCapacity:0];
        
        FMResultSet *rs = [db executeQuery:@"select * from bk_user_charge where ibillid = ? and operatortype <> 2 and (ichargetype = ? or ichargetype = ?) and cuserid = ?", @(SSJSpecialBillIdBalanceRollIn), @(SSJChargeIdTypeTransfer), @(SSJChargeIdTypeNormal), userID];
        
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
    }];
}

/**
 升级借贷流水；如果流水chargeid不是UUID_billID格式的话，要改成这种格式
 */
+ (void)upgradeLoanCharges:(NSArray<NSDictionary *> *)charges {
    NSMutableArray *chargeModels = [NSMutableArray array];
    for (NSDictionary *chargeInfo in charges) {
        if ([chargeInfo[@"operatortype"] intValue] == 2
            || [chargeInfo[@"ichargetype"] integerValue] != SSJChargeIdTypeLoan) {
            continue;
        }
        
        if ([chargeInfo[@"ichargeid"] containsString:@"_"]) {
            continue;
        }
        
        SSJLoanChargeModel *model = [[SSJLoanChargeModel alloc] init];
        model.chargeId = chargeInfo[@"ichargeid"];
        model.billId = chargeInfo[@"ibillid"];
        model.fundId = chargeInfo[@"ifunsid"];
        model.loanId = chargeInfo[@"cid"];
        model.userId = chargeInfo[@"cuserid"];
        model.money = [chargeInfo[@"imoney"] doubleValue];
        model.memo = chargeInfo[@"cmemo"];
        model.billDate = [NSDate dateWithString:chargeInfo[@"cbilldate"] formatString:@"yyyy-MM-dd"];
        model.writeDate = [NSDate dateWithString:chargeInfo[@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        [chargeModels addObject:model];
    }
    
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(SSJDatabase *db, BOOL *rollback) {
        NSError *error = nil;
        if (![SSJDatabaseVersion18 updateLoanChargesWithModels:chargeModels database:db error:&error]) {
            *rollback = YES;
        }
    }];
}

/**
 对周期转账流水进行排重
 */
+ (void)removeDuplicateTransferCharges:(NSString *)userID {
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(SSJDatabase *db, BOOL *rollback) {
        NSMutableArray *cids = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:@"select cid from bk_user_charge where operatortype <> 2 and cuserid = ? and ichargetype = ? group by cid having count(cid) > 2", userID, @(SSJChargeIdTypeCyclicTransfer)];
        while ([rs next]) {
            [cids addObject:[rs stringForColumn:@"cid"]];
        }
        [rs close];
        
        for (NSString *cid in cids) {
            NSMutableArray *reserveInfo = [NSMutableArray array];
            NSMutableArray *reserveCids = [NSMutableArray array];
            NSMutableArray *removedCids = [NSMutableArray array];
            
            rs = [db executeQuery:@"select ichargeid, cbilldate, imoney from bk_user_charge where cid = ? and cuserid = ? and ichargetype = ? and operatortype <> 2 order by cbilldate, imoney, cwritedate", cid, userID, @(SSJChargeIdTypeCyclicTransfer)];
            while ([rs next]) {
                NSString *chargeID = [rs stringForColumn:@"ichargeid"];
                if (reserveCids.count < 2) {
                    [reserveCids addObject:chargeID];
                    NSDictionary *info = @{@"cbilldate":[rs stringForColumn:@"cbilldate"],
                                           @"imoney":[rs stringForColumn:@"imoney"]};
                    [reserveInfo addObject:info];
                } else {
                    [removedCids addObject:chargeID];
                }
            }
            [rs close];
            
            for (NSString *chargeID in removedCids) {
                if (![db executeUpdate:@"update bk_user_charge set operatortype = 2, iversion = ?, cwritedate = ? where ichargeid = ?", chargeID]) {
                    *rollback = YES;
                    return;
                }
            }
            
            NSDictionary *info_1 = [reserveInfo firstObject];
            NSDictionary *info_2 = [reserveInfo lastObject];
            NSString *billDate_1 = info_1[@"cbilldate"];
            NSString *billDate_2 = info_2[@"cbilldate"];
            NSString *money_1 = info_1[@"imoney"];
            NSString *money_2 = info_2[@"imoney"];
            
            if (![billDate_1 isEqualToString:billDate_2]
                || [money_1 doubleValue] != [money_2 doubleValue]) {
                for (NSString *chargeID in reserveCids) {
                    if (![db executeUpdate:@"update bk_user_charge set operatortype = 2, iversion = ?, cwritedate = ? where ichargeid = ?", chargeID]) {
                        *rollback = YES;
                        return;
                    }
                }
            }
        }
    }];
}

@end
