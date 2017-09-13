//
//  SSJCreditCardStore.m
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJLocalNotificationStore.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJLocalNotificationStore.h"
#import "SSJLoanModel.h"
#import "SSJLoanHelper.h"
#import "SSJReminderItem.h"

@implementation SSJCreditCardStore

//+ (SSJCreditCardItem *)queryCreditCardDetailWithCardId:(NSString *)cardId {
//    SSJCreditCardItem *item = [[SSJCreditCardItem alloc]init];
//    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
//        NSString *userId = SSJUSERID();
//        FMResultSet *resultSet = [db executeQuery:@"select a.*, b.iquota, b.ibilldatesettlement, b.crepaymentdate, b.cbilldate, b.cremindid, b.itype from bk_fund_info a left join bk_user_credit b on a.cfundid = b.cfundid where a.cfundid = ? and a.cuserid = ?",cardId,userId];
//        if (!resultSet) {
//            return;
//        }
//        while([resultSet next]){
//            item.fundingID = cardId;
//            item.fundingName = [resultSet stringForColumn:@"cacctname"];
//            item.cardLimit = [resultSet doubleForColumn:@"iquota"];
//            item.settleAtRepaymentDay = [resultSet boolForColumn:@"ibilldatesettlement"];
//            item.cardBillingDay = [resultSet intForColumn:@"cbilldate"];
//            item.cardRepaymentDay = [resultSet intForColumn:@"crepaymentdate"];
//            item.fundingMemo = [resultSet stringForColumn:@"cmemo"];
//            item.cardColor = [resultSet stringForColumn:@"ccolor"];
//            item.remindId = [resultSet stringForColumn:@"cremindid"];
//            item.cardOder = [resultSet intForColumn:@"iorder"];
//            item.startColor = [resultSet stringForColumn:@"cstartColor"];
//            item.endColor = [resultSet stringForColumn:@"cendColor"];
//            item.cardType = [resultSet intForColumn:@"itype"];
//            if (item.cardType == SSJCrediteCardTypeAlipay) {
//                item.settleAtRepaymentDay = YES;
//            }
//        }
//        [resultSet close];
//        item.remindState = [db boolForQuery:@"select istate from bk_user_remind where cremindid = ? and cuserid = ?",item.remindId,userId];
//        NSString *currentDate = [[NSDate date]formattedDateWithFormat:@"yyyy-MM-dd"];
//        item.fundingAmount = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge a left join bk_share_books_member c on c.cbooksid = a.cbooksid and c.cmemberid = ?, bk_user_bill_type b where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or ichargetype = ?) and b.itype = 0 and a.ifunsid = ? and (c.istate = ? or c.istate is null or a.ibillid in ('13','14'))",userId,userId,currentDate,@(SSJChargeIdTypeLoan),cardId,@(SSJShareBooksMemberStateNormal)] - [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge a left join bk_share_books_member c on c.cbooksid = a.cbooksid and c.cmemberid = ?, bk_user_bill_type as b where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or ichargetype = ?) and b.itype = 1 and a.ifunsid = ? and (c.istate = ? or c.istate is null or a.ibillid in ('13','14'))",userId,userId,currentDate,@(SSJChargeIdTypeLoan),cardId,@(SSJShareBooksMemberStateNormal)] + [db doubleForQuery:@"select sum(repaymentmoney) from bk_credit_repayment where cuserid = ? and ccardId = ? and operatortype <> 2 and iinstalmentcount > 0",userId,cardId];
//        item.chargeCount = [db intForQuery:@"select count(1) from bk_user_charge where ifunsid = ? and cuserid = ? and operatortype <> 2",cardId,userId];
//        if ([db intForQuery:@"select count(1) from bk_credit_repayment where cuserid = ? and ccardId = ? and operatortype <> 2 and iinstalmentcount > 0",userId,cardId]) {
//            item.hasMadeInstalment = YES;
//        } else {
//            item.hasMadeInstalment = NO;
//        }
//    }];
//    return item;
//}

+ (void)syncSaveCreditCardWithCardItem:(SSJCreditCardItem *)item
                                   Error:(NSError **)error {
    //  保存提醒
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSError *tError = [self saveCreditCardWithCardItem:item inDatabase:db];
        SSJDispatch_main_async_safe(^{
            if (error) {
                *error = tError;
            }
        });
    }];
}

+ (void)asyncSaveCreditCardWithCardItem:(SSJCreditCardItem *)item
                                  Success:(void (^)(void))success
                                  failure:(void (^)(NSError *error))failure {
    //  保存提醒
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *tError = [self saveCreditCardWithCardItem:item inDatabase:db];
        if (tError) {
            SSJDispatch_main_async_safe(^{
                if (failure) {
                    failure(tError);
                }
            });
        } else {
            SSJDispatch_main_async_safe(^{
                if (success) {
                    success();
                }
            });
        }
    }];
}

+ (NSError *)saveCreditCardWithCardItem:(SSJCreditCardItem *)item
                               inDatabase:(FMDatabase *)db  {
    NSString *editeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString *userId = SSJUSERID();
    
    if (!item.fundingID.length) {
        item.fundingID = SSJUUID();
    }
    
    NSInteger maxOrder = [db intForQuery:@"select max(iorder) from bk_fund_info where cuserid = ? and operatortype <> 2",userId] + 1;

    NSString *fundParent;
    NSString *fundIcoin;

    if (item.cardType == SSJCrediteCardTypeAlipay) {
        fundParent = @"16";
        fundIcoin = @"ft_mayihuabei";
        item.settleAtRepaymentDay = YES;
    } else {
        fundParent = @"3";
        fundIcoin = @"ft_creditcard";
    }
    
    item.cardColor = item.startColor;

    // 判断是新增还是修改
    if (![db intForQuery:@"select count(1) from bk_fund_info where cfundid = ? and cuserid = ? and operatortype <> 2",item.fundingID,userId]) {
        // 插入资金账户表
        if (![db executeUpdate:@"insert into bk_fund_info (cfundid ,cacctname ,cicoin ,cparent ,ccolor ,cwritedate ,operatortype ,iversion ,cmemo ,cuserid , iorder ,idisplay, cstartcolor, cendcolor) values (?,?,?,?,?,?,0,?,?,?,?,1,?,?)",item.fundingID,item.fundingName,fundIcoin,fundParent,item.cardColor,editeDate,@(SSJSyncVersion()),item.fundingMemo,userId,@(maxOrder),item.startColor,item.endColor]) {
            return [db lastError];
        }
        
        double money = fabs(item.fundingAmount);
        
        if (item.fundingAmount > 0) {
            // 如果余额大于0,在流水里插入一条平帐收入
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f",money],@"1",item.fundingID,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                return [db lastError];
            }
        }else if(item.fundingAmount < 0){
            // 如果余额小于0,在流水里插入一条平帐支出
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f", money],@"2",item.fundingID,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                return [db lastError];
            }
        }
        
        // 插入信用卡表
        if (![db executeUpdate:@"insert into bk_user_credit (cfundid, iquota, cbilldate, crepaymentdate, cuserid, cwritedate, iversion, operatortype, cremindid, ibilldatesettlement, itype) values (?,?,?,?,?,?,?,0,?,?,?)",item.fundingID,@(item.cardLimit),@(item.cardBillingDay),@(item.cardRepaymentDay),userId,editeDate,@(SSJSyncVersion()),item.remindItem.remindId,@(item.settleAtRepaymentDay),@(item.cardType)]) {
            return [db lastError];
        }
    }else{
        
        // 修改资金账户
        if (![db executeUpdate:@"update bk_fund_info set cacctname = ? ,ccolor = ?,cwritedate = ?,operatortype = 1,iversion = ?,cmemo = ?,cstartcolor = ?,cendcolor = ? where cfundid = ? and cuserid = ?",item.fundingName,item.cardColor,editeDate,@(SSJSyncVersion()),item.fundingMemo,item.startColor,item.endColor,item.fundingID,userId]) {
            return [db lastError];
        }
        
        NSString *currentDate = [[NSDate date]formattedDateWithFormat:@"yyyy-MM-dd"];
        
        double originalBalance = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_user_bill_type as b where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or ichargetype = ?) and b.itype = 0 and a.ifunsid = ?",userId,currentDate,@(SSJChargeIdTypeLoan),item.fundingID] - [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_user_bill_type as b where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or ichargetype = ?) and b.itype = 1 and a.ifunsid = ?",userId,currentDate,@(SSJChargeIdTypeLoan),item.fundingID] + [db doubleForQuery:@"select sum(repaymentmoney) from bk_credit_repayment where cuserid = ? and ccardId = ? and operatortype <> 2 and iinstalmentcount > 0",userId,item.fundingID];
        
        double differenceBalance = item.fundingAmount - originalBalance;
        
        if (differenceBalance > 0) {
            // 如果余额大于0,在流水里插入一条平帐收入
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f",ABS(differenceBalance)],@"1",item.fundingID,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                return [db lastError];
            }
        }else if(differenceBalance < 0){
            // 如果余额小于0,在流水里插入一条平帐支出
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f", ABS(differenceBalance)],@"2",item.fundingID,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                return [db lastError];
            }
        }
        
        // 查询在信用卡表中有没有数据,如果没有则插入一条(对老的信用卡账户)
        if (![db intForQuery:@"select count(1) from bk_user_credit where cfundid = ? and cuserid = ? and operatortype <> 2",item.fundingID,userId]) {
            // 插入信用卡表
            if (![db executeUpdate:@"insert into bk_user_credit (cfundid, iquota, cbilldate, crepaymentdate, cuserid, cwritedate, iversion, operatortype, cremindid, ibilldatesettlement, itype) values (?,?,?,?,?,?,?,0,?,?,?)",item.fundingID,@(item.cardLimit),@(item.cardBillingDay),@(item.cardRepaymentDay),userId,editeDate,@(SSJSyncVersion()),item.remindItem.remindId,@(item.settleAtRepaymentDay),@(item.cardType)]) {
                return [db lastError];
            }
        }else{
            if (![db executeUpdate:@"update bk_user_credit set iquota = ?, cbilldate = ?, crepaymentdate = ?,  cwritedate = ?, iversion = ?, operatortype = 1, cremindid = ?, ibilldatesettlement = ? where cfundid = ? and cuserid = ?",@(item.cardLimit),@(item.cardBillingDay),@(item.cardRepaymentDay),editeDate,@(SSJSyncVersion()),item.remindItem.remindId,@(item.settleAtRepaymentDay),item.fundingID,userId]) {
                return [db lastError];
            }
        }
    }
    return nil;
}

+ (float)queryCreditCardBalanceForTheMonth:(NSInteger)month billingDay:(NSInteger)billingDay WithCardId:(NSString *)cardId{
    __block float fundingAmount;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        if (month > 12) {
            SSJDispatch_main_async_safe(^{
                [CDAutoHideMessageHUD showMessage:@"月份不能大于12"];
            });
            return;
        }
        
        NSInteger cardType = [db intForQuery:@"select itype from bk_user_credit where cfundid = ?",cardId];
        
        NSString *firstBillingDay;
        
        NSString *secondBillingDay;
        
        if (cardType == SSJCrediteCardTypeAlipay) {
            firstBillingDay = [[[NSDate dateWithYear:[NSDate date].year month:month day:billingDay] dateBySubtractingMonths:1] formattedDateWithFormat:@"yyyy-MM-dd"];
            secondBillingDay = [[[NSDate dateWithYear:[NSDate date].year month:month day:billingDay] dateBySubtractingDays:1 ] formattedDateWithFormat:@"yyyy-MM-dd"];
        } else {
            firstBillingDay = [[[[NSDate dateWithYear:[NSDate date].year month:month day:billingDay] dateBySubtractingMonths:1] dateByAddingDays:1] formattedDateWithFormat:@"yyyy-MM-dd"];
            secondBillingDay = [[NSDate dateWithYear:[NSDate date].year month:month day:billingDay] formattedDateWithFormat:@"yyyy-MM-dd"];
        }
        double cardExpense = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge a, bk_user_bill_type b where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.cuserid = ? and a.operatortype <> 2 and b.itype = 1 and a.cbilldate >= ? and a.cbilldate <= ? and a.ifunsid = ?",userId,firstBillingDay,secondBillingDay,cardId];
        fundingAmount = cardExpense;
    }];
    return fundingAmount;
}

+ (BOOL)deleteCreditCardWithCardItem:(SSJFinancingHomeitem *)item
                           writeDate:(NSString *)writeDate
             inDatabase:(FMDatabase *)db
              forUserId:(NSString *)userId
                  error:(NSError **)error{

    //删除信用卡表
    if (![db executeUpdate:@"update bk_user_credit set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and cfundid = ?",writeDate,@(SSJSyncVersion()),userId,item.fundingID]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    //删除资金账户表
    if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and cfundid = ?",writeDate,@(SSJSyncVersion()),userId,item.fundingID]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    //删除提醒表
    if (item.cardItem.remindItem) {
        if (![db executeUpdate:@"update bk_user_remind set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and cremindid = ?",writeDate,@(SSJSyncVersion()),userId,item.cardItem.remindItem.remindId]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        //取消提醒
        [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:item.cardItem.remindItem];
    }
    
    // 删除和此信用卡账户有关的借贷数据
    if (![SSJLoanHelper deleteLoanDataRelatedToFundID:item.fundingID writeDate:writeDate database:db error:error]) {
        return NO;
    }

    //删除资金账户所对应的周期转账
    if (![db executeUpdate:@"update bk_transfer_cycle set operatortype = 2 , cwritedate = ? , iversion = ? where (ctransferinaccountid = ? or ctransferoutaccountid = ?) and operatortype <> 2" , writeDate , @(SSJSyncVersion()) , item.fundingID , item.fundingID]) {
        return NO;
    };
    
    //删除资金帐户对应的周期记账
    if (![db executeUpdate:@"update bk_charge_period_config set operatortype = 2 , cwritedate = ? , iversion = ? where ifunsid = ? and operatortype <> 2" , writeDate , @(SSJSyncVersion()) , item.fundingID]) {
        return NO;
    };
    
    //删除流水表
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and ifunsid = ? and (ichargetype <> ? or cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ? and istate = ?))",writeDate,@(SSJSyncVersion()),userId,item.fundingID,@(SSJChargeIdTypeShareBooks),userId,@(SSJShareBooksMemberStateNormal)]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }

    return YES;
}

+ (void)saveCreditCardWithCardItem:(SSJCreditCardItem *)item
                        remindItem:(SSJReminderItem *)remindItem
                                Success:(void (^)(NSInteger operatortype))success
                                failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSError *terror;
        NSInteger operatortype = item.fundingID.length ? 1 : 0;
        if (!item.fundingID.length) {
            item.fundingID = SSJUUID();
        }
        terror = [self saveCreditCardWithCardItem:item inDatabase:db];
        if (terror) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        };
        if (item.remindItem) {
            remindItem.fundId = item.fundingID;
            terror = [SSJLocalNotificationStore saveReminderWithReminderItem:remindItem inDatabase:db];
            if (terror) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            };
        }
        if (success) {
            SSJDispatchMainAsync(^{
                success(operatortype);
            });
        }
    }];
}

@end
