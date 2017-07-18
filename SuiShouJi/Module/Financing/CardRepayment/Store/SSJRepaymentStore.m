//
//  SSJRepaymentStore.m
//  SuiShouJi
//
//  Created by ricky on 2016/11/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRepaymentStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJRepaymentStore

+ (SSJRepaymentModel *)queryRepaymentModelWithChargeItem:(SSJBillingChargeCellItem *)item{
    __block SSJRepaymentModel *model = [[SSJRepaymentModel alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        if (item.idType == SSJChargeIdTypeRepayment) {
            // 如果有还款id,则为账单分期,若没有,则是还款
            if (![item.billId isEqualToString:@"3"] && ![item.billId isEqualToString:@"4"]) {
                //是账单分期的情况
                FMResultSet *resultSet = [db executeQuery:@"select a.* , b.ifunsid, c.cacctname, d.cbilldate, d.crepaymentdate from bk_credit_repayment a, bk_user_charge b, bk_fund_info c, bk_user_credit d where a.crepaymentid = ? and a.crepaymentid = b.cid and b.ichargeid = ? and b.ifunsid = c.cfundid",item.sundryId,item.ID];
                while ([resultSet next]) {
                    model.repaymentId = item.sundryId;
                    model.cardId = [resultSet stringForColumn:@"CCARDID"];
                    model.cardName = [resultSet stringForColumn:@"cacctname"];
                    model.repaymentMonth = [NSDate dateWithString:[resultSet stringForColumn:@"crepaymentmonth"] formatString:@"yyyy-MM"];
                    model.applyDate = [NSDate dateWithString:[resultSet stringForColumn:@"CAPPLYDATE"] formatString:@"yyyy-MM-dd"] ;
                    model.repaymentSourceFoundId = [resultSet stringForColumn:@"ifunsid"];
                    model.repaymentSourceFoundName = [resultSet stringForColumn:@"cacctname"];
                    model.repaymentMoney = [NSDecimalNumber decimalNumberWithString:[resultSet stringForColumn:@"REPAYMENTMONEY"]];
                    model.instalmentCout = [resultSet intForColumn:@"IINSTALMENTCOUNT"];
                    if ([resultSet stringForColumn:@"IPOUNDAGERATE"]) {
                        model.poundageRate = [NSDecimalNumber decimalNumberWithString:[resultSet stringForColumn:@"IPOUNDAGERATE"]];
                    }
                    model.memo = [resultSet stringForColumn:@"CMEMO"];
                    model.cardRepaymentDay = [resultSet intForColumn:@"crepaymentdate"];
                    model.cardBillingDay = [resultSet intForColumn:@"cbilldate"];
                    NSDate *billDate = [NSDate dateWithString:item.billDate formatString:@"yyyy-MM-dd"];
                    model.currentInstalmentCout = [billDate monthsFrom:model.applyDate] + 1;
                }
            }else {
                //是还款的情况
//                NSString *fundParent = [db stringForQuery:@"select cparent from bk_fund_info where cfundid = ?",item.fundId];
                model.applyDate = [NSDate dateWithString:item.billDate formatString:@"yyyy-MM-dd"];
                NSString *repaymentStr = [db stringForQuery:@"select crepaymentMonth from bk_credit_repayment where crepaymentid = ?",item.sundryId];
                model.repaymentMonth = [NSDate dateWithString:repaymentStr formatString:@"yyyy-MM"];
                model.repaymentId = item.sundryId;
                if ([item.billId isEqualToString:@"3"]) {
                    model.cardId = item.fundId;
                    model.cardName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",model.cardId];
                    model.repaymentSourceFoundId = [db stringForQuery:@"select ifunsid from bk_user_charge where cwritedate = ? and ichargeid <> ? and ichargetype = ?",item.editeDate,item.ID,@(SSJChargeIdTypeRepayment)];
                    model.repaymentSourceFoundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",model.repaymentSourceFoundId];
                    model.repaymentChargeId = item.ID;
                    model.sourceChargeId = [db stringForQuery:@"select ichargeid from bk_user_charge where cwritedate = ? and ichargeid <> ? and ichargetype = ?",item.editeDate,item.ID,@(SSJChargeIdTypeRepayment)];
                }else {
                    model.cardId = [db stringForQuery:@"select ifunsid from bk_user_charge where cwritedate = ? and ichargeid <> ? and ichargetype = ?",item.editeDate,item.ID,@(SSJChargeIdTypeRepayment)];
                    model.cardName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",model.cardId];
                    model.repaymentSourceFoundId = item.fundId;
                    model.repaymentSourceFoundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",item.fundId];
                    model.sourceChargeId = item.ID;
                    model.repaymentChargeId = [db stringForQuery:@"select ichargeid from bk_user_charge where cwritedate = ? and ichargeid <> ? and ichargetype = ?",item.editeDate,item.ID,@(SSJChargeIdTypeRepayment)];   
                }
                double repaymentMoney = [item.money doubleValue];
                NSString *repamentMoneyStr = [NSString stringWithFormat:@"%f",fabs(repaymentMoney)];
                model.repaymentMoney = [NSDecimalNumber decimalNumberWithString:repamentMoneyStr];
                model.memo = item.chargeMemo;
            }
        }
    }];
    return model;
}

+ (void)saveRepaymentWithRepaymentModel:(SSJRepaymentModel *)model
                                Success:(void (^)(void))success
                                failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *userID = SSJUSERID();
        NSString *booksId = [db stringForQuery:@"select CCURRENTBOOKSID from bk_user where cuserid = ?",userID];
        if (!booksId.length) {
            booksId = userID;
        }
        if (!model.instalmentCout) {
            // 如果期数为0则是还款
            if (!model.repaymentId.length) {
                // 如果是新建,插入两笔转账流水
                model.repaymentChargeId = SSJUUID();
                model.sourceChargeId = SSJUUID();
                model.repaymentId = SSJUUID();
                // 在还款表插入一条数据
                if (![db executeUpdate:@"insert into bk_credit_repayment (crepaymentid, iinstalmentcount, capplydate, ccardid, repaymentmoney, ipoundagerate, cmemo, cuserid, iversion, operatortype, cwritedate, crepaymentmonth) values (?, 0, ?, ?, ?, 0, ?, ?, ?, 1, ?, ?)",model.repaymentId,[model.applyDate formattedDateWithFormat:@"yyyy-MM-dd"],model.cardId,model.repaymentMoney,model.memo,userID,@(SSJSyncVersion()),writeDate,[model.repaymentMonth formattedDateWithFormat:@"yyyy-MM"]]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                
                // 转入流水
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, ichargetype, cid) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)",model.repaymentChargeId,booksId,@"3",model.cardId,model.repaymentMoney,[model.applyDate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,@(SSJChargeIdTypeRepayment),model.repaymentId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                // 转出流水
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, ichargetype, cid) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)",model.sourceChargeId,booksId,@"4",model.repaymentSourceFoundId,model.repaymentMoney,[model.applyDate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,@(SSJChargeIdTypeRepayment),model.repaymentId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
            }else {
                // 修改还款表数据
                if (![db executeUpdate:@"update bk_credit_repayment set capplydate = ?, repaymentmoney = ?, cmemo = ? where crepaymentid = ? and cuserid = ?",model.applyDate,model.repaymentMoney,model.memo,model.repaymentId,userID]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                
                // 修改转出流水
                if (![db executeUpdate:@"update bk_user_charge set imoney = ?, cbilldate = ?, cmemo = ?, iversion = ?, operatortype = 1, cwritedate = ? where ichargeid = ? and cuserid = ?",model.repaymentMoney,[model.applyDate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,@(SSJSyncVersion()),writeDate,model.repaymentChargeId,userID]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                // 转出流水
                if (![db executeUpdate:@"update bk_user_charge set ifunsid = ?, imoney = ?, cbilldate = ?, cmemo = ?, iversion = ?, operatortype = 1, cwritedate = ? where ichargeid = ? and cuserid = ?",model.repaymentSourceFoundId,model.repaymentMoney,[model.applyDate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,@(SSJSyncVersion()),writeDate,model.sourceChargeId,userID]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
            }
        }else{
            // 如果不为0则为账单分期
            if (!model.repaymentId.length) {
                model.repaymentId = SSJUUID();
                //如果是新建
                // 在还款表插入一条数据
                if (![db executeUpdate:@"insert into bk_credit_repayment (crepaymentid, iinstalmentcount, capplydate, ccardid, repaymentmoney, ipoundagerate, cmemo, cuserid, iversion, operatortype, cwritedate, crepaymentmonth) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)",model.repaymentId,@(model.instalmentCout),[model.applyDate formattedDateWithFormat:@"yyyy-MM-dd"],model.cardId,model.repaymentMoney,model.poundageRate,model.memo,userID,@(SSJSyncVersion()),writeDate,[model.repaymentMonth formattedDateWithFormat:@"yyyy-MM"]]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                for (int i = 0; i < model.instalmentCout; i ++) {
                    NSString *chargeid = SSJUUID();
                    NSString *poundageChargeId = SSJUUID();
                    NSDate *billdate = model.applyDate;
                    billdate = [billdate dateByAddingMonths:i];
                    double principalMoney = [model.repaymentMoney doubleValue] / model.instalmentCout;
                    NSString *principalMoneyStr = [[NSString stringWithFormat:@"%f",principalMoney] ssj_moneyDecimalDisplayWithDigits:2];
                    if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, ichargetype, cid) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)",chargeid,booksId,@"11",model.cardId,principalMoneyStr,[billdate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,@(SSJChargeIdTypeRepayment),model.repaymentId]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                    }
                    if ([model.poundageRate doubleValue]) {
                        double poundageMoney = [model.repaymentMoney doubleValue] * [model.poundageRate doubleValue];
                        NSString *poundageMoneyStr = [[NSString stringWithFormat:@"%f",poundageMoney] ssj_moneyDecimalDisplayWithDigits:2];
                        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, ichargetype, cid) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)",poundageChargeId,booksId,@"12",model.cardId,poundageMoneyStr,[billdate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,@(SSJChargeIdTypeRepayment),model.repaymentId]) {
                            *rollback = YES;
                            if (failure) {
                                SSJDispatch_main_async_safe(^{
                                    failure([db lastError]);
                                });
                            }
                        }
                    }
                }
            }else {
                // 如果是修改,首先将原来所有的跟这条分期有关的流水全部删除,然后将新的流水插入
                // 修改还款表数据
                if (![db executeUpdate:@"update bk_credit_repayment set iinstalmentcount = ?, capplydate = ?, repaymentmoney = ?, ipoundagerate = ?, cmemo = ?, iversion = ?, cwritedate = ? where crepaymentid = ? and cuserid = ?",@(model.instalmentCout),[model.applyDate formattedDateWithFormat:@"yyyy-MM-dd"],model.repaymentMoney,model.poundageRate,model.memo,@(SSJSyncVersion()),writeDate,model.repaymentId,userID]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                
                if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 , iversion = ?, cwritedate = ? where cid = ? and ichargetype = ?",@(SSJSyncVersion()),writeDate,model.repaymentId,@(SSJChargeIdTypeRepayment)]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                for (int i = 0; i < model.instalmentCout; i ++) {
                    NSString *chargeid = SSJUUID();
                    NSString *poundageChargeId = SSJUUID();
                    NSDate *billdate = model.applyDate;
                    billdate = [billdate dateByAddingMonths:i];
                    double principalMoney = [model.repaymentMoney doubleValue] / model.instalmentCout;
                    NSString *principalMoneyStr = [[NSString stringWithFormat:@"%f",principalMoney] ssj_moneyDecimalDisplayWithDigits:2];
                    if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, ichargetype, cid) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)",chargeid,booksId,@"11",model.cardId,principalMoneyStr,[billdate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,@(SSJChargeIdTypeRepayment),model.repaymentId]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                    }
                    if ([model.poundageRate doubleValue]) {
                        double poundageMoney = [model.repaymentMoney doubleValue] * [model.poundageRate doubleValue];
                        NSString *poundageMoneyStr = [[NSString stringWithFormat:@"%f",poundageMoney] ssj_moneyDecimalDisplayWithDigits:2];
                        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, ichargetype, cid) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)",poundageChargeId,booksId,@"12",model.cardId,poundageMoneyStr,[billdate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,@(SSJChargeIdTypeRepayment),model.repaymentId]) {
                            *rollback = YES;
                            if (failure) {
                                SSJDispatch_main_async_safe(^{
                                    failure([db lastError]);
                                });
                            }
                        }
                    }
                }
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (void)deleteRepaymentWithRepaymentModel:(SSJRepaymentModel *)model
                                Success:(void (^)(void))success
                                failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *userId = SSJUSERID();
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 2, iversion = ?, cwritedate = ? where cuserid = ? and ichargetype = ? and cid = ?",@(SSJSyncVersion()),writeDate,userId,@(SSJChargeIdTypeRepayment),model.repaymentId]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
        };
        if (![db executeUpdate:@"update bk_credit_repayment set operatortype = 2, iversion = ?, cwritedate = ? where cuserid = ? and crepaymentid = ?",@(SSJSyncVersion()),writeDate,userId,model.repaymentId]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
        };
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (BOOL)checkTheMoneyIsValidForTheRepaymentWithRepaymentModel:(SSJRepaymentModel *)model{
    __block BOOL isInvalid = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSDate *firstBillDay = [[NSDate dateWithYear:model.repaymentMonth.year month:model.repaymentMonth.month day:model.cardBillingDay] dateBySubtractingMonths:1];
        NSDate *secondBillDay = [[NSDate dateWithYear:model.repaymentMonth.year month:model.repaymentMonth.month day:model.cardBillingDay] dateBySubtractingDays:1];
        double cardSum = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_user_bill_type as b where a.ibillid = b.cbillid and a.cuserid = ? and a.operatortype <> 2 and b.itype = 0 and a.ifunsid = ? and a.cbilldate >= ? and a.cbilldate <= ?",userid,model.cardId,[firstBillDay formattedDateWithFormat:@"yyyy-MM-dd"],[secondBillDay formattedDateWithFormat:@"yyyy-MM-dd"]] - [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_user_bill_type as b where a.ibillid = b.cbillid and a.cuserid = ? and a.operatortype <> 2 and b.itype = 1 and a.ifunsid = ? and a.cbilldate >= ? and a.cbilldate <= ?",userid,model.cardId,[firstBillDay formattedDateWithFormat:@"yyyy-MM-dd"],[secondBillDay formattedDateWithFormat:@"yyyy-MM-dd"]];
        
        if ([model.repaymentMoney doubleValue] > fabs(cardSum) || cardSum > 0) {
            isInvalid = NO;
        }
    }];
    return isInvalid;
}

@end
