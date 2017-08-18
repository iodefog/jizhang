//
//  SSJFinancingHomeHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/3/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJCreditCardStore.h"
#import "SSJCreditCardItem.h"
#import "SSJLoanHelper.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJBillingChargeCellItem.h"

@implementation SSJFinancingHomeHelper
+ (void)queryForFundingListWithSuccess:(void(^)(NSArray<SSJFinancingHomeitem *> *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *fundingList = [[NSMutableArray alloc]init];
        FMResultSet * fundingResult = [db executeQuery:@"select a.* from bk_fund_info a where a.cparent != 'root' and a.operatortype <> 2 and a.cuserid = ? order by a.iorder asc, a.cparent asc , a.cwritedate desc",userid];
        if (!fundingResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        int count = 1;
        while ([fundingResult next]) {
            SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
            item.fundingColor = [fundingResult stringForColumn:@"CCOLOR"];
            item.fundingIcon = [fundingResult stringForColumn:@"CICOIN"];
            item.fundingID = [fundingResult stringForColumn:@"CFUNDID"];
            item.fundingName = [fundingResult stringForColumn:@"CACCTNAME"];
            item.fundingParent = [fundingResult stringForColumn:@"CPARENT"];
            item.fundingParentName = [self fundParentNameForFundingParent:item.fundingParent];
            item.fundingMemo = [fundingResult stringForColumn:@"CMEMO"];
            item.fundingOrder = [fundingResult intForColumn:@"IORDER"];
            item.startColor = [fundingResult stringForColumn:@"CSTARTCOLOR"];
            item.endColor = [fundingResult stringForColumn:@"CENDCOLOR"];

            if (item.fundingOrder == 0) {
                item.fundingOrder = count;
            }
            if ([fundingResult boolForColumn:@"idisplay"] || (![item.fundingParent isEqualToString:@"11"] && ![item.fundingParent isEqualToString:@"10"])) {
                [fundingList addObject:item];
            }
            count ++;
        }
        [fundingResult close];
        NSString *currentDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
        for (SSJFinancingHomeitem *item in fundingList) {
            item.fundingAmount = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge a, bk_user_bill_type b left join bk_share_books_member c on c.cbooksid = a.cbooksid and c.cmemberid = ? where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.operatortype <> 2 and (a.cbilldate <= ? or ichargetype = ?) and b.itype = 0 and a.ifunsid = ? and (c.istate = ? or c.istate is null or a.ibillid in ('13','14'))",userid,currentDate,@(SSJChargeIdTypeLoan),item.fundingID,@(SSJShareBooksMemberStateNormal)] - [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_user_bill_type as b left join bk_share_books_member c on c.cbooksid = a.cbooksid and c.cmemberid = ?  where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.operatortype <> 2 and (a.cbilldate <= ? or ichargetype = ?) and b.itype = 1 and a.ifunsid = ? and (c.istate = ? or c.istate is null or a.ibillid in ('13','14'))",userid,currentDate,@(SSJChargeIdTypeLoan),item.fundingID,@(SSJShareBooksMemberStateNormal)];
            item.chargeCount = [db intForQuery:@"select count(1) from bk_user_charge where ifunsid = ? and cuserid = ? and operatortype <> 2",item.fundingID,userid];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(fundingList);
            });
        }
    }];
}

+ (SSJFinancingHomeitem *)fundingItemWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
    item.fundingColor = [set stringForColumn:@"CCOLOR"];
    item.fundingIcon = [set stringForColumn:@"CICOIN"];
    item.fundingID = [set stringForColumn:@"CFUNDID"];
    item.fundingName = [set stringForColumn:@"CACCTNAME"];
    item.fundingParent = [set stringForColumn:@"CPARENT"];
    item.fundingMemo = [set stringForColumn:@"CMEMO"];
    item.fundingOrder = [set intForColumn:@"IORDER"];
    return item;
}


+ (void)SaveFundingOderWithItems:(NSArray <SSJFinancingHomeitem *> *)items error:(NSError **)error{
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i = 0; i < items.count; i++) {
            NSString *sql;
            SSJBaseCellItem *item = [items ssj_safeObjectAtIndex:i];
            if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
                SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)item;
                fundingItem.fundingOrder = i + 1;
                sql = [NSString stringWithFormat:@"update bk_fund_info set iorder = %ld , cwritedate = '%@' , iversion = %@ , operatortype = 1 where cfundid = '%@'",(long)fundingItem.fundingOrder,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),fundingItem.fundingID];
            }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                cardItem.cardOder = i + 1;
                sql = [NSString stringWithFormat:@"update bk_fund_info set iorder = %ld , cwritedate = '%@' , iversion = %@ , operatortype = 1 where cfundid = '%@'",(long)cardItem.cardOder,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),cardItem.cardId];
            }
            [db executeUpdate:sql];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    }];
}

+ (void)deleteFundingWithFundingItem:(SSJBaseCellItem *)item
                          deleteType:(BOOL)type
                             Success:(void(^)())success
                             failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *userId = SSJUSERID();
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
            // 如果是借贷
            SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)item;
            if ([fundingItem.fundingParent isEqualToString:@"10"] || [fundingItem.fundingParent isEqualToString:@"11"]) {
                if (!type) {
                    //如果保留数据只要将响应的借贷隐藏
                    if (![db executeUpdate:@"update bk_fund_info set idisplay = 0 , cwritedate = ? , iversion = ?, operatortype = 1 where cfundid = ?",writeDate,@(SSJSyncVersion()),fundingItem.fundingID]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                }else{
                    //如果删掉数据只要将响应的借贷隐藏
                    if (![db executeUpdate:@"update bk_fund_info set idisplay = 0 , cwritedate = ? , iversion = ?, operatortype = 1 where cfundid = ?",writeDate,@(SSJSyncVersion()),fundingItem.fundingID]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                    FMResultSet *resultSet = [db executeQuery:@"select * from bk_loan where cthefundid = ?",fundingItem.fundingID];
                    if (!resultSet) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    }
                    
                    NSMutableArray *models = [NSMutableArray array];
                    while ([resultSet next]) {
                        SSJLoanModel *loanModel = [[SSJLoanModel alloc] init];
                        loanModel.ID = [resultSet stringForColumn:@"loanid"];
                        loanModel.userID = [resultSet stringForColumn:@"cuserid"];
                        loanModel.lender = [resultSet stringForColumn:@"lender"];
                        loanModel.jMoney = [resultSet doubleForColumn:@"jmoney"];
                        loanModel.fundID = [resultSet stringForColumn:@"cthefundid"];
                        loanModel.targetFundID = [resultSet stringForColumn:@"ctargetfundid"];
                        loanModel.endTargetFundID = [resultSet stringForColumn:@"cetarget"];
                        loanModel.borrowDate = [NSDate dateWithString:[resultSet stringForColumn:@"cborrowdate"] formatString:@"yyyy-MM-dd"];
                        loanModel.repaymentDate = [NSDate dateWithString:[resultSet stringForColumn:@"crepaymentdate"] formatString:@"yyyy-MM-dd"];
                        loanModel.endDate = [NSDate dateWithString:[resultSet stringForColumn:@"cenddate"] formatString:@"yyyy-MM-dd"];
                        loanModel.rate = [resultSet doubleForColumn:@"rate"];
                        loanModel.memo = [resultSet stringForColumn:@"memo"];
                        loanModel.remindID = [resultSet stringForColumn:@"cremindid"];
                        loanModel.interest = [resultSet boolForColumn:@"interest"];
                        loanModel.closeOut = [resultSet boolForColumn:@"iend"];
                        loanModel.type = [resultSet intForColumn:@"itype"];
                        loanModel.operatorType = [resultSet intForColumn:@"operatorType"];
                        loanModel.version = [resultSet longLongIntForColumn:@"iversion"];
                        loanModel.writeDate = [NSDate dateWithString:[resultSet stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
                        [models addObject:loanModel];
                    }
                    [resultSet close];
                    
                    for (SSJLoanModel *loanModel in models) {
                        if (![SSJLoanHelper deleteLoanModel:loanModel inDatabase:db forUserId:userId error:NULL]) {
                            if (failure) {
                                *rollback = YES;
                                SSJDispatchMainAsync(^{
                                    failure([db lastError]);
                                });
                            }
                            return;
                        };
                    }
                }
            }else{
                //如果是普通资金账户
                if (!type) {
                    // 如果保留数据只要删掉资金账户
                    if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?",writeDate,@(SSJSyncVersion()),fundingItem.fundingID]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                }else{
                    // 如果不保留先删掉资金账户
                    if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?",writeDate,@(SSJSyncVersion()),fundingItem.fundingID]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                    
                    //找出所有和当前资金账户有关的借贷
                    FMResultSet *resultSet = [db executeQuery:@"select * from bk_loan where loanid in (select cid from bk_user_charge where ifunsid = ? and operatortype <> 2 and ichargetype = ?)", fundingItem.fundingID,@(SSJChargeIdTypeLoan)];
                    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
                    while ([resultSet next]) {
                        SSJLoanModel *loanModel = [[SSJLoanModel alloc] init];
                        loanModel.ID = [resultSet stringForColumn:@"loanid"];
                        loanModel.userID = [resultSet stringForColumn:@"cuserid"];
                        loanModel.lender = [resultSet stringForColumn:@"lender"];
                        loanModel.jMoney = [resultSet doubleForColumn:@"jmoney"];
                        loanModel.fundID = [resultSet stringForColumn:@"cthefundid"];
                        loanModel.targetFundID = [resultSet stringForColumn:@"ctargetfundid"];
                        loanModel.endTargetFundID = [resultSet stringForColumn:@"cetarget"];
                        loanModel.borrowDate = [NSDate dateWithString:[resultSet stringForColumn:@"cborrowdate"] formatString:@"yyyy-MM-dd"];
                        loanModel.repaymentDate = [NSDate dateWithString:[resultSet stringForColumn:@"crepaymentdate"] formatString:@"yyyy-MM-dd"];
                        loanModel.endDate = [NSDate dateWithString:[resultSet stringForColumn:@"cenddate"] formatString:@"yyyy-MM-dd"];
                        loanModel.rate = [resultSet doubleForColumn:@"rate"];
                        loanModel.memo = [resultSet stringForColumn:@"memo"];
                        loanModel.remindID = [resultSet stringForColumn:@"cremindid"];
                        loanModel.interest = [resultSet boolForColumn:@"interest"];
                        loanModel.closeOut = [resultSet boolForColumn:@"iend"];
                        loanModel.type = [resultSet intForColumn:@"itype"];
                        loanModel.operatorType = [resultSet intForColumn:@"operatorType"];
                        loanModel.version = [resultSet longLongIntForColumn:@"iversion"];
                        loanModel.writeDate = [NSDate dateWithString:[resultSet stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
                        [tempArr addObject:loanModel];
                    }
                    [resultSet close];
                    for (SSJLoanModel *model in tempArr) {
                        if (![SSJLoanHelper deleteLoanModel:model inDatabase:db forUserId:userId error:NULL]) {
                            if (failure) {
                                *rollback = YES;
                                SSJDispatchMainAsync(^{
                                    failure([db lastError]);
                                });
                            }
                            return;
                        };
                    }
                    
                    // 删掉账户所对应的转账
                    if (![self deleteTransferChargeInDataBase:db withFundId:fundingItem.fundingID userId:userId error:NULL]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    }
                    
                    //删除资金账户所对应的流水
                    if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 , cwritedate = ? , iversion = ? where ifunsid = ? and operatortype <> 2 and (ichargetype <> ? or cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ? and istate = ?))",writeDate,@(SSJSyncVersion()),fundingItem.fundingID,@(SSJChargeIdTypeShareBooks),userId,@(SSJShareBooksMemberStateNormal)]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                    
                }
            }
        }else{
            // 如果是信用卡账户
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
            if (!type) {
                //删掉资金账户
                if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?",writeDate,@(SSJSyncVersion()),cardItem.cardId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                };
                //删掉信用卡
                if (![db executeUpdate:@"update bk_user_credit set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?",writeDate,@(SSJSyncVersion()),cardItem.cardId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                };
                //删掉提醒
                if (cardItem.remindId.length) {
                    if (![db executeUpdate:@"update bk_user_remind set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and cremindid = ?",writeDate,@(SSJSyncVersion()),userId,cardItem.remindId]) {
                        *rollback = YES;
                        SSJDispatch_main_async_safe(^{
                            if (failure) {
                                failure([db lastError]);
                            }
                            return;
                        });
                    }
                    //取消提醒
                    SSJReminderItem *remindItem = [[SSJReminderItem alloc]init];
                    remindItem.remindId = cardItem.remindId;
                    [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:remindItem];
                }
            }else{
                // 删掉账户所对应的转账
                if (![self deleteTransferChargeInDataBase:db withFundId:cardItem.cardId userId:userId error:NULL]) {
                    if (failure) {
                        *rollback = YES;
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
                
                if (![SSJCreditCardStore deleteCreditCardWithCardItem:cardItem inDatabase:db forUserId:userId error:NULL]) {
                    *rollback = YES;
                    SSJDispatch_main_async_safe(^{
                        if (failure) {
                            failure([db lastError]);
                        }
                        return;
                    });
                };
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (BOOL)deleteTransferChargeInDataBase:(FMDatabase *)db withFundId:(NSString *)fundId userId:(NSString *)userId error:(NSError *)error{
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    FMResultSet *transferResult = [db executeQuery:@"select * from bk_user_charge where ifunsid = ? and cuserid = ? and operatortype <> 2 and ibillid in (3,4)",fundId,userId];
    if (!transferResult) {
        error = [db lastError];
    }
    while ([transferResult next]) {
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc]init];
        item.billId = [transferResult stringForColumn:@"ibillid"];
        item.ID = [transferResult stringForColumn:@"ichargeid"];
        item.editeDate = [transferResult stringForColumn:@"cwritedate"];
        item.billDate = [transferResult stringForColumn:@"cbilldate"];
        item.money = [transferResult stringForColumn:@"imoney"];
        [tempArr addObject:item];
    }
    [transferResult close];
    
    for (SSJBillingChargeCellItem *item in tempArr) {
        NSDate *writeDate = [NSDate dateWithString:item.editeDate formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSDate *maxDate = [writeDate dateByAddingSeconds:1];
        NSDate *minDate = [writeDate dateBySubtractingSeconds:1];
        NSString *maxDateStr = [maxDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *minDateStr = [minDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if ([item.billId isEqualToString:@"3"]) {
            if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 where cuserid = ? and cbilldate = ? and (cwritedate between ? and ?) and imoney = ? and ibillid = 4",userId,item.billDate,minDateStr,maxDateStr,item.money]) {
                error = [db lastError];
                return NO;
            }
        }else{
            if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 where cuserid = ? and cbilldate = ? and (cwritedate between ? and ?) and imoney = ? and ibillid = 3",userId,item.billDate,minDateStr,maxDateStr,item.money]) {
                error = [db lastError];
                return NO;
            }
        }
    }
    
    return YES;
}

+ (SSJFinancingHomeitem *)queryFundItemWithFundingId:(NSString *)fundingId{
    __block SSJFinancingHomeitem *fundItem = [[SSJFinancingHomeitem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *result = [db executeQuery:@"select a.* from bk_fund_info  a where a.cparent != 'root' and a.operatortype <> 2 and a.cuserid = ? and a.cfundid = ?",userid,fundingId];
        while ([result next]) {
            fundItem = [self fundingItemWithResultSet:result inDatabase:db];
        }
    }];
    return fundItem;
}

+ (SSJFinancingHomeitem *)queryfirstFundItem{
    __block SSJFinancingHomeitem *fundItem = [[SSJFinancingHomeitem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *result = [db executeQuery:@"select a.* from bk_fund_info  a where a.cparent != 'root' and a.operatortype <> 2 and a.cuserid = ? limit 1",userid];
        while ([result next]) {
            fundItem = [self fundingItemWithResultSet:result inDatabase:db];
        }
    }];
    return fundItem;
}

+ (NSString *)fundIconForFundingParent:(NSString *)parent {
    switch ([parent integerValue]) {
        case 1:
            return @"ft_cash";
            break;
            
        case 2:
            return @"ft_chuxuka";
            break;
            
        case 3:
            return @"ft_creditcard";
            break;
            
        case 4:
            return @"ft_invest";
            break;
            
        case 5:
            return @"ft_huobijijin";
            break;
            
        case 6:
            return @"ft_shiwuka";
            break;
            
        case 7:
            return @"ft_wangluochongzhi";
            break;
            
        case 8:
            return @"ft_house";
            break;
            
        case 9:
            return @"ft_yingshouqian";
            break;
            
        case 10:
            return @"ft_jiechukuan";
            break;
            
        case 11:
            return @"ft_qiankuan";
            break;
            
        case 12:
            return @"ft_shebao";
            break;
            
        case 13:
            return @"ft_weixin";
            break;
            
        case 14:
            return @"ft_zhifubao";
            break;
            
        case 15:
            return @"ft_others";
            break;
   
        default:
            break;
    }
    return @"";
}

+ (NSString *)fundParentNameForFundingParent:(NSString *)parent {
    switch ([parent integerValue]) {
        case 1:
            return @"现金";
            break;
            
        case 2:
            return @"储蓄卡";
            break;
            
        case 3:
            return @"信用卡";
            break;
            
        case 4:
            return @"投资账户";
            break;
            
        case 5:
            return @"货币基金";
            break;
            
        case 6:
            return @"实物储值卡";
            break;
            
        case 7:
            return @"网络充值账户";
            break;
            
        case 8:
            return @"住房公积金";
            break;
            
        case 9:
            return @"应收钱款";
            break;
            
        case 10:
            return @"借出款";
            break;
            
        case 11:
            return @"欠款";
            break;
            
        case 12:
            return @"社保";
            break;
            
        case 13:
            return @"微信钱包";
            break;
            
        case 14:
            return @"支付宝";
            break;
            
        case 15:
            return @"其他";
            break;
            
        default:
            break;
    }
    return @"";
}

@end
