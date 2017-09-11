//
//  SSJFundingTransferListStore.m
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJRegularManager.h"

NSString *SSJFundingTransferStoreMonthKey = @"SSJFundingTransferStoreMonthKey";
NSString *SSJFundingTransferStoreListKey = @"SSJFundingTransferStoreListKey";

@implementation SSJFundingTransferStore
+ (void)queryForFundingTransferListWithSuccess:(void(^)(NSArray <NSDictionary *>*result))success
                                       failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        NSError *error = nil;
        NSArray *oldTransferCharges = [self queryOldTransferChargesInDatabase:db error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        NSArray *newTransferCharges = [self queryNewTransferChargesInDatabase:db error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        NSMutableArray *tempList = [NSMutableArray arrayWithCapacity:oldTransferCharges.count + newTransferCharges.count];
        [tempList addObjectsFromArray:oldTransferCharges];
        [tempList addObjectsFromArray:newTransferCharges];
        
        // 按转账日期降序，若转账日期相同，则按金额降序
        [tempList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            SSJFundingTransferDetailItem *item1 = obj1;
            SSJFundingTransferDetailItem *item2 = obj2;
            
            NSDate *date1 = [NSDate dateWithString:item1.transferDate formatString:@"yyyy-MM-dd"];
            NSDate *date2 = [NSDate dateWithString:item2.transferDate formatString:@"yyyy-MM-dd"];
            
            if ([date1 compare:date2] == NSOrderedAscending) {
                return NSOrderedDescending;
            } else if ([date1 compare:date2] == NSOrderedDescending) {
                return NSOrderedAscending;
            } else {
                if ([item1.transferMoney doubleValue] > [item2.transferMoney doubleValue]) {
                    return NSOrderedAscending;
                } else if ([item1.transferMoney doubleValue] < [item2.transferMoney doubleValue]) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        
        NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:oldTransferCharges.count + newTransferCharges.count];
        NSDate *lastDate = nil;
        
        // 相同年份月份的数据整合到一起
        for (SSJFundingTransferDetailItem *item in tempList) {
            NSDate *currentDate = [NSDate dateWithString:item.transferDate formatString:@"yyyy-MM-dd"];
            if (!lastDate || lastDate.year != currentDate.year || lastDate.month != currentDate.month) {
                NSMutableDictionary *monthInfo = [NSMutableDictionary dictionary];
                [monthInfo setObject:currentDate forKey:SSJFundingTransferStoreMonthKey];
                
                NSMutableArray *list = [NSMutableArray array];
                [list addObject:item];
                [monthInfo setObject:list forKey:SSJFundingTransferStoreListKey];
                
                [resultList addObject:monthInfo];
            } else {
                NSMutableDictionary *monthInfo = [resultList lastObject];
                NSMutableArray *list = monthInfo[SSJFundingTransferStoreListKey];
                [list addObject:item];
            }
            lastDate = currentDate;
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(resultList);
            });
        }
    }];
}

+ (void)deleteFundingTransferWithItem:(SSJFundingTransferDetailItem *)item
                              Success:(void(^)())success
                              failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *userid = SSJUSERID();
        NSString *writeDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 , cwritedate = ? , iversion = ? where ichargeid in (?,?) and cuserid = ?",writeDate,@(SSJSyncVersion()),item.transferInChargeId,item.transferOutChargeId,userid]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            *rollback = YES;
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (void)saveCycleTransferRecordWithID:(NSString *)ID
                  transferInAccountId:(NSString *)transferInAccountId
                 transferOutAccountId:(NSString *)transferOutAccountId
                                money:(double)money
                                 memo:(nullable NSString *)memo
                      cyclePeriodType:(SSJCyclePeriodType)cyclePeriodType
                            beginDate:(NSString *)beginDate
                              endDate:(nullable NSString *)endDate
                              success:(nullable void (^)(BOOL isExisted))success
                              failure:(nullable void (^)(NSError *error))failure {
    
    NSString *userId = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL existed = [db boolForQuery:@"select count(1) from bk_transfer_cycle where cuserid = ? and icycleid = ?", userId, ID];
        
        BOOL successful = YES;
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        if (existed) {
            successful = [db executeUpdate:@"update bk_transfer_cycle set ctransferinaccountid = ?, ctransferoutaccountid = ?, imoney = ?, cmemo = ?, icycletype = ?, cbegindate = ?, cenddate = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cuserid = ? and icycleid = ? and operatortype <> 2", transferInAccountId, transferOutAccountId, @(money), memo, @(cyclePeriodType), beginDate, endDate, writeDateStr, @(SSJSyncVersion()), userId, ID];
        } else {
            successful = [db executeUpdate:@"insert into bk_transfer_cycle (icycleid, cuserid, ctransferinaccountid, ctransferoutaccountid, imoney, cmemo, icycletype, cbegindate, cenddate, clientadddate, cwritedate, iversion, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", ID, userId, transferInAccountId, transferOutAccountId, @(money), memo, @(cyclePeriodType), beginDate, endDate, writeDateStr, writeDateStr, @(SSJSyncVersion()), @0];
        }
        
        if (!successful) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (cyclePeriodType == SSJCyclePeriodTypeOnce) {
            if (![self createOnceTransferChargesInDatabase:db ID:ID transferInAccountId:transferInAccountId transferOutAccountId:transferOutAccountId money:money memo:memo billDate:beginDate userId:userId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        } else {
            if (![SSJRegularManager supplementCyclicTransferForUserId:userId inDatabase:db]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(existed);
            });
        }
    }];
}

/**
 创建仅一次周期转账对应的流水
 */
+ (BOOL)createOnceTransferChargesInDatabase:(FMDatabase *)db
                                         ID:(NSString *)ID
                        transferInAccountId:(NSString *)transferInAccountId
                       transferOutAccountId:(NSString *)transferOutAccountId
                                      money:(double)money
                                       memo:(nullable NSString *)memo
                                   billDate:(NSString *)billDate
                                     userId:(NSString *)userId {
    
    // 查询是否有匹配仅一次转账的流水
    BOOL chargeExisted = [db boolForQuery:@"select count(1) from bk_user_charge where cuserid = ? and cid like (? || '-%') and operatortype != 2 and cbilldate = ? and ichargetype = 5", userId, ID, billDate];
    
    if (!chargeExisted) {
        
        // 查询当前周期转账生成的流水cid后缀最大值
        int cidSuffix = [db intForQuery:@"select max(cast(substr(uc.cid, length(tc.icycleid) + 2) as int)) from bk_user_charge as uc, bk_transfer_cycle as tc where uc.cuserid = ? and uc.ichargetype = 5 and uc.cid like (? || '-%')", userId, ID] + 1;
        
        NSString *cid = [NSString stringWithFormat:@"%@-%d", ID, cidSuffix];
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 创建转入流水
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cmemo, ichargetype, cid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", SSJUUID(), userId, @(money), @3, transferInAccountId, billDate, memo, @5, cid, @(SSJSyncVersion()), @0, writeDateStr]) {
            return NO;
        }
        
        // 创建转出流水
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cmemo, ichargetype, cid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", SSJUUID(), userId, @(money), @4, transferOutAccountId, billDate, memo, @5, cid, @(SSJSyncVersion()), @0, writeDateStr]) {
            return NO;
        }
    }
    
    return YES;
}

+ (void)saveTransferChargeWithTransInChargeId:(NSString *)transInChargeId
                             transOutChargeId:(NSString *)transOutChargeId
                                transInAcctId:(NSString *)transInAcctId
                               transOutAcctId:(NSString *)transOutAcctId
                                        money:(double)money
                                         memo:(NSString *)memo
                                     billDate:(NSString *)billDate
                                      success:(nullable void (^)())success
                                      failure:(nullable void (^)(NSError *error))failure {
    
    if (!transInChargeId || !transOutChargeId) {
        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"转入流水id／转出流水id不能为nil"}]);
        return;
    }
    
    if (!transInAcctId || !transOutAcctId) {
        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"转入资金账户id／转出资金账户id不能为nil"}]);
        return;
    }
    
    if (!billDate) {
        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"billdate不能为nil"}]);
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 更新转入流水
        if (![db executeUpdate:@"update bk_user_charge set imoney = ?, ifunsid = ?, cbilldate = ?, cmemo = ?, cwritedate = ?, iversion = ?, operatortype = 1 where ichargeid = ? and operatortype != 2", @(money), transInAcctId, billDate, memo, writeDateStr, @(SSJSyncVersion()), transInChargeId]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 更新转出流水
        if (![db executeUpdate:@"update bk_user_charge set imoney = ?, ifunsid = ?, cbilldate = ?, cmemo = ?, cwritedate = ?, iversion = ?, operatortype = 1 where ichargeid = ? and operatortype != 2", @(money), transOutAcctId, billDate, memo, writeDateStr, @(SSJSyncVersion()), transOutChargeId]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

+ (void)deleteCycleTransferRecordWithID:(NSString *)ID
                                success:(nullable void (^)())success
                                failure:(nullable void (^)(NSError *error))failure {
    
    NSString *userid = SSJUSERID();
    NSString *writeDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"update bk_transfer_cycle set operatortype = 2, cwritedate = ?, iversion = ? where cuserid = ? and icycleid = ?", writeDate, @(SSJSyncVersion()), userid, ID]) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
        } else {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
        }
    }];
}

+ (void)updateCycleTransferRecordStateWithID:(NSString *)ID
                                      opened:(BOOL)opened
                                     success:(nullable void (^)())success
                                     failure:(nullable void (^)(NSError *error))failure {
    
    NSString *userid = SSJUSERID();
    NSString *writeDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"update bk_transfer_cycle set istate = ?, operatortype = 1, cwritedate = ?, iversion = ? where cuserid = ? and icycleid = ?", @(opened), writeDate, @(SSJSyncVersion()), userid, ID]) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
        } else {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
        }
    }];
}

+ (void)queryCycleTransferRecordsListWithSuccess:(nullable void (^)(NSArray <NSDictionary *>*))success
                                         failure:(nullable void (^)(NSError *error))failure {
    
    NSString *userid = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select tc.*, fund_in.cacctname as transferInAcctName, fund_in.cicoin as transferInAcctIcon, fund_in.cfundid as transferInAcctID, fund_out.cacctname as transferOutAcctName, fund_out.cicoin as transferOutAcctIcon, fund_out.cfundid as transferOutAcctID from bk_transfer_cycle as tc, bk_fund_info as fund_in, bk_fund_info as fund_out where tc.ctransferinaccountid = fund_in.cfundid and tc.ctransferoutaccountid = fund_out.cfundid and tc.cuserid = ? and tc.cuserid = fund_in.cuserid and tc.cuserid = fund_out.cuserid and tc.icycletype <> -1 and tc.operatortype <> 2 order by tc.cbegindate desc, tc.imoney desc", userid];
        
        if (!resultSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        NSDate *lastDate = nil;
        
        while ([resultSet next]) {
            SSJFundingTransferDetailItem *item = [[SSJFundingTransferDetailItem alloc] init];
            item.ID = [resultSet stringForColumn:@"icycleid"];
            item.transferMoney = [NSString stringWithFormat:@"%.2f", [resultSet doubleForColumn:@"imoney"]];
            item.beginDate = [resultSet stringForColumn:@"cbegindate"];
            item.endDate = [resultSet stringForColumn:@"cenddate"];
            item.transferInName = [resultSet stringForColumn:@"transferInAcctName"];
            item.transferOutName = [resultSet stringForColumn:@"transferOutAcctName"];
            item.transferInImage = [resultSet stringForColumn:@"transferInAcctIcon"];
            item.transferOutImage = [resultSet stringForColumn:@"transferOutAcctIcon"];
            item.transferInId = [resultSet stringForColumn:@"transferInAcctID"];
            item.transferOutId = [resultSet stringForColumn:@"transferOutAcctID"];
            item.transferMemo = [resultSet stringForColumn:@"cmemo"];
            item.cycleType = [resultSet intForColumn:@"icycletype"];
            item.opened = [resultSet boolForColumn:@"istate"];
            
            NSDate *currentDate = [NSDate dateWithString:item.beginDate formatString:@"yyyy-MM-dd"];
            
            if (!lastDate || lastDate.year != currentDate.year || lastDate.month != currentDate.month) {
                NSMutableDictionary *monthInfo = [[NSMutableDictionary alloc] init];
                [monthInfo setObject:currentDate forKey:SSJFundingTransferStoreMonthKey];
                
                NSMutableArray *list = [[NSMutableArray alloc] init];
                [list addObject:item];
                [monthInfo setObject:list forKey:SSJFundingTransferStoreListKey];
                
                [result addObject:monthInfo];
            } else {
                NSMutableDictionary *monthInfo = [result lastObject];
                NSMutableArray *list = monthInfo[SSJFundingTransferStoreListKey];
                [list addObject:item];
            }
            
            lastDate = currentDate;
        }
        [resultSet close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(result);
            });
        }
    }];
}

+ (NSArray <SSJFundingTransferDetailItem *>*)queryOldTransferChargesInDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet * transferResult = [db executeQuery:@"select substr(a.cbilldate,0,7) as cmonth , a.* , b.cacctname , b.cfundid , b.cicoin , b.operatortype as fundoperatortype , b.cparent from bk_user_charge as a, bk_fund_info as b where a.ibillid in (3,4) and a.operatortype != 2 and a.cuserid = ? and a.ifunsid = b.cfundid and (a.ichargetype = ? or a.ichargetype = ?) order by cmonth desc , cwritedate desc , ibillid asc",SSJUSERID(),@(SSJChargeIdTypeNormal),@(SSJChargeIdTypeTransfer)];
    
    if (!transferResult) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:0];
    
    while ([transferResult next]) {
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        item.money = [transferResult stringForColumn:@"IMONEY"];
        item.ID = [transferResult stringForColumn:@"ICHARGEID"];
        item.fundId = [transferResult stringForColumn:@"IFUNSID"];
        item.fundImage = [transferResult stringForColumn:@"CICOIN"];
        item.editeDate = [transferResult stringForColumn:@"CWRITEDATE"];
        item.billId = [transferResult stringForColumn:@"IBILLID"];
        item.chargeImage = [transferResult stringForColumn:@"CIMGURL"];
        item.chargeThumbImage = [transferResult stringForColumn:@"THUMBURL"];
        item.chargeMemo = [transferResult stringForColumn:@"CMEMO"];
        item.billDate = [transferResult stringForColumn:@"CBILLDATE"];
        item.fundName = [transferResult stringForColumn:@"CACCTNAME"];
        item.fundOperatorType = [transferResult intForColumn:@"fundoperatortype"];
        item.fundParent = [transferResult stringForColumn:@"cparent"];
        
        SSJFundingTransferDetailItem *detailItem = nil;
        if (tempArr.count == 1) {
            [tempArr addObject:item];
            detailItem = [self transferItemWithArray:tempArr];
            [tempArr removeAllObjects];
        }else{
            [tempArr addObject:item];
        }
        
        if (detailItem) {
            [resultList addObject:detailItem];
        }
    }
    
    return resultList;
}

+ (NSArray <SSJFundingTransferDetailItem *>*)queryNewTransferChargesInDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet *resultSet = [db executeQuery:@"select uc.*, fi.cacctname, fi.cfundid, fi.cicoin, fi.operatortype as fundoperatortype, fi.cparent from bk_user_charge as uc, bk_fund_info as fi where uc.ibillid in (3,4) and uc.operatortype != 2 and uc.cuserid = ? and uc.cuserid = fi.cuserid and uc.ifunsid = fi.cfundid and uc.ichargetype = ? order by uc.cid", SSJUSERID(), @(SSJChargeIdTypeCyclicTransfer)];
    
    if (!resultSet) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:0];
    
    while ([resultSet next]) {
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        item.money = [resultSet stringForColumn:@"IMONEY"];
        item.ID = [resultSet stringForColumn:@"ICHARGEID"];
        item.fundId = [resultSet stringForColumn:@"IFUNSID"];
        item.fundImage = [resultSet stringForColumn:@"CICOIN"];
        item.editeDate = [resultSet stringForColumn:@"CWRITEDATE"];
        item.billId = [resultSet stringForColumn:@"IBILLID"];
        item.chargeImage = [resultSet stringForColumn:@"CIMGURL"];
        item.chargeThumbImage = [resultSet stringForColumn:@"THUMBURL"];
        item.chargeMemo = [resultSet stringForColumn:@"CMEMO"];
        item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
        item.fundName = [resultSet stringForColumn:@"CACCTNAME"];
        item.fundOperatorType = [resultSet intForColumn:@"fundoperatortype"];
        item.fundParent = [resultSet stringForColumn:@"cparent"];
        
        SSJFundingTransferDetailItem *detailItem = nil;
        if (tempArr.count == 1) {
            [tempArr addObject:item];
            detailItem = [self transferItemWithArray:tempArr];
            [tempArr removeAllObjects];
        }else{
            [tempArr addObject:item];
        }
        
        if (detailItem) {
            [resultList addObject:detailItem];
        }
    }
    
    return resultList;
}

+ (SSJFundingTransferDetailItem *)transferItemWithArray:(NSArray <SSJBillingChargeCellItem *>*)array{
    if (array.count != 2) {
        SSJPRINT(@"匹配失败,请检查数据");
        return nil;
    }
    
    SSJBillingChargeCellItem *transferInItem;
    SSJBillingChargeCellItem *transferOutItem;
    for (int i = 0; i < array.count; i ++) {
        SSJBillingChargeCellItem *item = [array ssj_safeObjectAtIndex:i];
        if ([item.billId isEqualToString:@"3"]) {
            transferInItem = [array ssj_safeObjectAtIndex:i];
        }else{
            transferOutItem = [array ssj_safeObjectAtIndex:i];
        }
    }
    if (![transferInItem.billId isEqualToString:@"3"]) {
        SSJPRINT(@"匹配失败,请检查数据");
        return nil;
    }
    if (![transferInItem.money isEqualToString:transferOutItem.money]) {
        SSJPRINT(@"匹配失败,请检查数据");
        return nil;
    }
    if (![transferOutItem.billId isEqualToString:@"4"]) {
        SSJPRINT(@"匹配失败,请检查数据");
        return nil;
    }
    
    SSJFundingTransferDetailItem *item = [[SSJFundingTransferDetailItem alloc]init];
    item.transferMoney = transferInItem.money;
    item.transferDate = transferInItem.billDate;
    item.transferInId = transferInItem.fundId;
    item.transferOutId = transferOutItem.fundId;
    item.transferInName = transferInItem.fundName;
    item.transferOutName = transferOutItem.fundName;
    item.transferInImage = transferInItem.fundImage;
    item.transferOutImage = transferOutItem.fundImage;
    item.transferMemo = transferInItem.chargeMemo;
    item.transferInChargeId = transferInItem.ID;
    item.transferOutChargeId = transferOutItem.ID;
    item.transferInFundOperatorType = transferInItem.fundOperatorType;
    item.transferOutFundOperatorType = transferOutItem.fundOperatorType;
    item.editable = YES;
    if ([transferInItem.fundParent isEqualToString:@"11"] || [transferOutItem.fundParent isEqualToString:@"11"]) {
        item.editable = NO;
    }
    if ([transferInItem.fundParent isEqualToString:@"10"] || [transferOutItem.fundParent isEqualToString:@"10"]) {
        item.editable = NO;
    }
    return item;
}

+ (void)queryFundingTransferDetailItemWithBillingChargeCellItem:(SSJBillingChargeCellItem *)chargeItem
                                                        success:(void (^)(SSJFundingTransferDetailItem *))success
                                                        failure:(nullable void (^)(NSError *error))failure {
    
    NSString *userId = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        SSJFundingTransferDetailItem *tansferItem = [[SSJFundingTransferDetailItem alloc]init];
        
        if ([chargeItem.billId integerValue] == 3) {
            tansferItem.transferDate = chargeItem.billDate;
            tansferItem.transferInId = chargeItem.fundId;
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
            tansferItem.transferMoney = [chargeItem.money stringByTrimmingCharactersInSet:set];
            tansferItem.transferInName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",tansferItem.transferInId];
            tansferItem.transferInImage = [db stringForQuery:@"select cicoin from bk_fund_info where cfundid = ?",tansferItem.transferInId];
            tansferItem.transferMemo = chargeItem.chargeMemo;
            tansferItem.transferInChargeId = chargeItem.ID;
            
            // 查询转出流水数据
            tansferItem.transferOutName = chargeItem.transferSource;
            FMResultSet *rs = [db executeQuery:@"select uc.ichargeid, uc.ifunsid, fi.cicoin from bk_user_charge uc, bk_fund_info fi where uc.ifunsid = fi.cfundid and uc.cid = ? and uc.ichargetype = ? and uc.ichargeid <> ?", chargeItem.sundryId, @(SSJChargeIdTypeCyclicTransfer), chargeItem.ID];
            while ([rs next]) {
                tansferItem.transferOutChargeId = [rs stringForColumn:@"ichargeid"];
                tansferItem.transferOutId = [rs stringForColumn:@"ifunsid"];
                tansferItem.transferOutImage = [rs stringForColumn:@"cicoin"];
            }
            [rs close];
            
//            NSString *transferInParent = [db stringForQuery:@"select cparent from bk_fund_info where cfundid = ?",tansferItem.transferInId];
//            NSString *transferOutParent = [db stringForQuery:@"select cparent from bk_fund_info where cfundid = ?",tansferItem.transferOutId];
            
        } else {
            tansferItem.transferDate = chargeItem.billDate;
            tansferItem.transferOutId = chargeItem.fundId;
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
            tansferItem.transferMoney = [chargeItem.money stringByTrimmingCharactersInSet:set];
            
            tansferItem.transferOutName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",chargeItem.fundId];
            tansferItem.transferOutImage = [db stringForQuery:@"select cicoin from bk_fund_info where cfundid = ?",tansferItem.transferOutId];
            tansferItem.transferMemo = chargeItem.chargeMemo;
            tansferItem.transferOutChargeId = chargeItem.ID;
            tansferItem.transferInName = chargeItem.transferSource;
            
            // 查询转入流水数据
            FMResultSet *rs = [db executeQuery:@"select uc.ichargeid, uc.ifunsid, fi.cicoin from bk_user_charge uc, bk_fund_info fi where uc.ifunsid = fi.cfundid and uc.cid = ? and uc.ichargetype = ? and uc.ichargeid <> ?", chargeItem.sundryId, @(SSJChargeIdTypeCyclicTransfer), chargeItem.ID];
            while ([rs next]) {
                tansferItem.transferInChargeId = [rs stringForColumn:@"ichargeid"];
                tansferItem.transferInId = [rs stringForColumn:@"ifunsid"];
                tansferItem.transferInImage = [rs stringForColumn:@"cicoin"];
            }
            [rs close];
//            NSString *transferInParent = [db stringForQuery:@"select cparent from bk_fund_info where cfundid = ?",tansferItem.transferInId];
//            NSString *transferOutParent = [db stringForQuery:@"select cparent from bk_fund_info where cfundid = ?",tansferItem.transferOutId];
        }
        
        if (success) {
            SSJDispatchMainSync(^(){
                success(tansferItem);
            });
        }
    }];
}

@end
