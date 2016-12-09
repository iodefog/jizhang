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
#import "SSJDailySumChargeTable.h"

@implementation SSJCreditCardStore

+ (SSJCreditCardItem *)queryCreditCardDetailWithCardId:(NSString *)cardId{
    SSJCreditCardItem *item = [[SSJCreditCardItem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        FMResultSet *resultSet = [db executeQuery:@"select a.* , b.iquota , b.ibilldatesettlement , b.crepaymentdate , b.cbilldate , b.cremindid from bk_fund_info a left join bk_user_credit b on a.cfundid = b.cfundid where a.cfundid = ? and a.cuserid = ?",cardId,userId];
        if (!resultSet) {
            return;
        }
        while([resultSet next]){
            item.cardId = cardId;
            item.cardName = [resultSet stringForColumn:@"cacctname"];
            item.cardLimit = [resultSet doubleForColumn:@"iquota"];
            item.settleAtRepaymentDay = [resultSet boolForColumn:@"ibilldatesettlement"];
            item.cardBillingDay = [resultSet intForColumn:@"cbilldate"];
            item.cardRepaymentDay = [resultSet intForColumn:@"crepaymentdate"];
            item.cardMemo = [resultSet stringForColumn:@"cmemo"];
            item.cardColor = [resultSet stringForColumn:@"ccolor"];
            item.remindId = [resultSet stringForColumn:@"cremindid"];
            item.cardOder = [resultSet intForColumn:@"iorder"];
        }
        [resultSet close];
        item.remindState = [db boolForQuery:@"select istate from bk_user_remind where cremindid = ? and cuserid = ?",item.remindId,userId];
        NSString *currentDate = [[NSDate date]formattedDateWithFormat:@"yyyy-MM-dd"];
        item.cardBalance = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or length(a.loanid) > 0) and b.itype = 0 and a.ifunsid = ?",userId,currentDate,cardId] - [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or length(a.loanid) > 0) and b.itype = 1 and a.ifunsid = ?",userId,currentDate,cardId];
        item.chargeCount = [db intForQuery:@"select count(1) from bk_user_charge where ifunsid = ? and cuserid = ? and operatortype <> 2",cardId,userId];
    }];
    return item;
}

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
                               inDatabase:(FMDatabase *)db {
    NSString *editeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString *userId = SSJUSERID();
    
    if (!item.cardId.length) {
        item.cardId = SSJUUID();
    }
    
    NSInteger maxOrder = [db intForQuery:@"select max(iorder) from bk_fund_info where cuserid = ? and operatortype <> 2",userId];
    maxOrder ++;

    // 判断是新增还是删除
    if (![db intForQuery:@"select count(1) from bk_fund_info where cfundid = ? and cuserid = ? and operatortype <> 2",item.cardId,userId]) {
        // 插入资金帐户表
        if (![db executeUpdate:@"insert into bk_fund_info (cfundid ,cacctname ,cicoin ,cparent ,ccolor ,cwritedate ,operatortype ,iversion ,cmemo ,cuserid , iorder ,idisplay) values (?,?,?,3,?,?,0,?,?,?,?,1)",item.cardId,item.cardName,@"ft_creditcard",item.cardColor,editeDate,@(SSJSyncVersion()),item.cardMemo,userId,@(maxOrder)]) {
            return [db lastError];
        }
        
        if (item.cardBalance > 0) {
            // 如果余额大于0,在流水里插入一条平帐收入
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f",item.cardBalance],@"1",item.cardId,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                return [db lastError];
            }
        }else if(item.cardBalance < 0){
            // 如果余额小于0,在流水里插入一条平帐支出
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f", - item.cardBalance],@"2",item.cardId,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                return [db lastError];
            }
        }
        
        // 插入信用卡表
        if (![db executeUpdate:@"insert into bk_user_credit (cfundid, iquota, cbilldate, crepaymentdate, cuserid, cwritedate, iversion, operatortype, cremindid, ibilldatesettlement) values (?,?,?,?,?,?,?,0,?,?)",item.cardId,@(item.cardLimit),@(item.cardBillingDay),@(item.cardRepaymentDay),userId,editeDate,@(SSJSyncVersion()),item.remindId,@(item.settleAtRepaymentDay)]) {
            return [db lastError];
        }
    }else{
        // 修改资金帐户
        if (![db executeUpdate:@"update bk_fund_info set cacctname = ? ,ccolor = ?,cwritedate = ?,operatortype = 1,iversion = ?,cmemo = ? where cfundid = ? and cuserid = ?",item.cardName,item.cardColor,editeDate,@(SSJSyncVersion()),item.cardMemo,item.cardId,userId]) {
            return [db lastError];
        }
        
        NSString *currentDate = [[NSDate date]formattedDateWithFormat:@"yyyy-MM-dd"];
        double originalBalance = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or length(a.loanid) > 0) and b.itype = 0 and a.ifunsid = ?",userId,currentDate,item.cardId] - [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or length(a.loanid) > 0) and b.itype = 1 and a.ifunsid = ?",userId,currentDate,item.cardId];
        
        double differenceBalance = item.cardBalance - originalBalance;
        
        if (differenceBalance > 0) {
            // 如果余额大于0,在流水里插入一条平帐收入
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f",differenceBalance],@"1",item.cardId,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                return [db lastError];
            }
        }else if(differenceBalance < 0){
            // 如果余额小于0,在流水里插入一条平帐支出
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f", - differenceBalance],@"2",item.cardId,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                return [db lastError];
            }
        }
        
        // 查询在信用卡表中有没有数据,如果没有则插入一条(对老的信用卡账户)
        if (![db intForQuery:@"select count(1) from bk_user_credit where cfundid = ? and cuserid = ? and operatortype <> 2",item.cardId,userId]) {
            // 插入信用卡表
            if (![db executeUpdate:@"insert into bk_user_credit (cfundid, iquota, cbilldate, crepaymentdate, cuserid, cwritedate, iversion, operatortype, cremindid, ibilldatesettlement) values (?,?,?,?,?,?,?,0,?,?)",item.cardId,@(item.cardLimit),@(item.cardBillingDay),@(item.cardRepaymentDay),userId,editeDate,@(SSJSyncVersion()),item.remindId,@(item.settleAtRepaymentDay)]) {
                return [db lastError];
            }
        }else{
            if (![db executeUpdate:@"update bk_user_credit set iquota = ?, cbilldate = ?, crepaymentdate = ?,  cwritedate = ?, iversion = ?, operatortype = 1, cremindid = ?, ibilldatesettlement = ? where cfundid = ? and cuserid = ?",@(item.cardLimit),@(item.cardBillingDay),@(item.cardRepaymentDay),editeDate,@(SSJSyncVersion()),item.remindId,@(item.settleAtRepaymentDay),item.cardId,userId]) {
                return [db lastError];
            }
        }
    }
    return nil;
}

+ (float)queryCreditCardBalanceForTheMonth:(NSInteger)month billingDay:(NSInteger)billingDay WithCardId:(NSString *)cardId{
    __block float cardBalance;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        if (month > 12) {
            SSJDispatch_main_async_safe(^{
                [CDAutoHideMessageHUD showMessage:@"月份不能大于12"];
            });
            return;
        }
        NSString *firstBillingDay = [[NSDate dateWithYear:[NSDate date].year month:month - 1 day:billingDay] formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *secondBillingDay = [[NSDate dateWithYear:[NSDate date].year month:month day:billingDay] formattedDateWithFormat:@"yyyy-MM-dd"];
        double cardExpense = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge a, bk_bill_type b where a.ibillid =  b.id and a.cuserid = ? and a.operatortype <> 2 and b.itype = 1 and a.cbilldate >= ? and a.cbilldate < ? and a.ifunsid = ?",userId,firstBillingDay,secondBillingDay,cardId];
        cardBalance = cardExpense;
    }];
    return cardBalance;
}

+ (BOOL)deleteCreditCardWithCardItem:(SSJCreditCardItem *)item
             inDatabase:(FMDatabase *)db
              forUserId:(NSString *)userId
                  error:(NSError **)error{
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    //删除信用卡表
    if (![db executeUpdate:@"update bk_user_credit set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and cfundid = ?",writeDate,@(SSJSyncVersion()),userId,item.cardId]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    //删除资金帐户表
    if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and cfundid = ?",writeDate,@(SSJSyncVersion()),userId,item.cardId]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    //删除提醒表
    if (item.remindId.length) {
        if (![db executeUpdate:@"update bk_user_remind set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and cremindid = ?",writeDate,@(SSJSyncVersion()),userId,item.remindId]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        //取消提醒
        SSJReminderItem *remindItem = [[SSJReminderItem alloc]init];
        remindItem.remindId = item.remindId;
        [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:remindItem];
    }
    FMResultSet *resultSet = [db executeQuery:@"select * from bk_loan where loanid in (select loanid from bk_user_charge where ifunsid = ? and operatortype <> 2)", item.cardId];
    if (!resultSet) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
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
            if (error) {
                *error = [db lastError];
            }
            return NO;
        };
    }
    //删除流水表
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and ifunsid = ?",writeDate,@(SSJSyncVersion()),userId,item.cardId]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    //更新日常统计表
    if (![SSJDailySumChargeTable updateDailySumChargeForUserId:userId inDatabase:db]) {
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
        NSInteger operatortype = item.cardId.length ? 1 : 0;
        if (!item.cardId.length) {
            item.cardId = SSJUUID();
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
        if (item.remindId.length) {
            remindItem.fundId = item.cardId;
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
