//
//  SSJRepaymentStore.m
//  SuiShouJi
//
//  Created by ricky on 2016/11/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRepaymentStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJRepaymentModel.h"

@implementation SSJRepaymentStore

+ (SSJRepaymentModel *)queryRepaymentModelWithChargeItem:(SSJBillingChargeCellItem *)item{
    __block SSJRepaymentModel *model = [[SSJRepaymentModel alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        if (item.idType == SSJChargeIdTypeRepayment) {
            // 如果有还款id,则为账单分期,若没有,则是还款
            if (item.sundryId.length) {
                //是账单分期的情况
                FMResultSet *resultSet = [db executeQuery:@"select a.* , b.ifunsid, c.cacctname from bk_credit_repayment a, bk_user_charge b, bk_fund_info c where a.crepaymentid = ? and a.id = b.id and b.ichargeid <> ? and b.ifunsid = c.acctname",item.sundryId,item.ID];
                while ([resultSet next]) {
                    model.repaymentId = item.sundryId;
                    model.cardId = [resultSet stringForColumn:@"CCARDID"];
                    model.applyDate = [resultSet stringForColumn:@"CAPPLYDATE"];
                    model.repaymentSourceFoundId = [resultSet stringForColumn:@"ifunsid"];
                    model.repaymentSourceFoundName = [resultSet stringForColumn:@"cacctname"];
                    model.repaymentMoney = [NSDecimalNumber decimalNumberWithString:[resultSet stringForColumn:@"REPAYMENTMONEY"]];
                    model.instalmentCout = [resultSet intForColumn:@"IINSTALMENTCOUNT"];
                    model.poundageRate = [NSDecimalNumber decimalNumberWithString:[resultSet stringForColumn:@"IPOUNDAGERATE"]];
                    model.memo = [resultSet stringForColumn:@"CMEMO"];
                    NSDate *applyDate = [NSDate dateWithString:model.applyDate formatString:@"yyyy-MM"];
                    NSDate *billDate = [NSDate dateWithString:item.billDate formatString:@"yyyy-MM"];
                    model.currentInstalmentCout = [billDate monthsFrom:applyDate] + 1;
                }
            }else {
                //是还款的情况
                NSString *fundParent = [db stringForQuery:@"select cparent from bk_fund_info where cfundid = ?",item.fundId];
                if ([fundParent isEqualToString:@"3"]) {
                    model.cardId = item.fundId;
                    model.repaymentSourceFoundId = [db stringForQuery:@"select ifunsid from bk_user_charge where cwritedate = ? and ichargeid <> ? and itype = ?",item.editeDate,item.ID,SSJChargeIdTypeRepayment];
                    model.repaymentSourceFoundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",model.repaymentSourceFoundId];
                    model.repaymentChargeId = item.ID;
                    model.sourceChargeId = [db stringForQuery:@"select ichargeid from bk_user_charge where cwritedate = ? and ichargeid <> ? and itype = ?",item.editeDate,item.ID,SSJChargeIdTypeRepayment];
                } else{
                    model.cardId = [db stringForQuery:@"select ifunsid from bk_user_charge where cwritedate = ? and ichargeid <> ? and itype = ?",item.editeDate,item.ID,SSJChargeIdTypeRepayment];
                    model.repaymentSourceFoundId = item.fundId;
                    model.repaymentSourceFoundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",item.fundId];
                    model.sourceChargeId = item.ID;
                    model.repaymentChargeId = [db stringForQuery:@"select ichargeid from bk_user_charge where cwritedate = ? and ichargeid <> ? and itype = ?",item.editeDate,item.ID,SSJChargeIdTypeRepayment];
                }
                model.repaymentMoney = [NSDecimalNumber decimalNumberWithString:item.money];
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
            if (!model.repaymentChargeId.length) {
                // 如果是新建,插入两笔转账流水
                model.repaymentChargeId = SSJUUID();
                model.sourceChargeId = SSJUUID();
                // 转入流水
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, itype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)",model.repaymentChargeId,booksId,@"3",model.cardId,model.repaymentMoney,model.applyDate,model.memo,userID,@(SSJSyncVersion()),writeDate,SSJChargeIdTypeRepayment]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                // 转出流水
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, itype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)",model.sourceChargeId,booksId,@"4",model.repaymentSourceFoundId,model.repaymentMoney,model.applyDate,model.memo,userID,@(SSJSyncVersion()),writeDate,SSJChargeIdTypeRepayment]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
            }else {
                // 修改转出流水
                if (![db executeUpdate:@"update bk_user_charge set imoney = ?, cbilldate = ?, cmemo = ?, iversion = ?, operatortype = 1, cwritedate = ? where ichargeid = ? and cuserid = ?",model.repaymentMoney,model.applyDate,model.memo,@(SSJSyncVersion()),writeDate,model.repaymentChargeId,userID]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                // 转出流水
                if (![db executeUpdate:@"update bk_user_charge set ifunsid, imoney = ?, cbilldate = ?, cmemo = ?, iversion = ?, operatortype = 1, cwritedate = ? where ichargeid = ? and cuserid = ?",model.repaymentSourceFoundId,model.repaymentMoney,model.applyDate,model.memo,@(SSJSyncVersion()),writeDate,model.sourceChargeId,userID]) {
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
                for (int i = 0; i < model.instalmentCout; i ++) {
                    NSString *chargeid = SSJUUID();
                    NSDate *billdate = [NSDate dateWithString:model.applyDate formatString:@"yyyy-MM-dd"];
                    billdate = [billdate dateByAddingMonths:i];
                    if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, itype, id) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)",chargeid,booksId,@"11",model.cardId,model.repaymentMoney,[billdate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,SSJChargeIdTypeRepayment,model.repaymentId]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                    }
                    if (model.poundageRate) {
                        float poundageMoney = [model.repaymentMoney doubleValue] * [model.poundageRate doubleValue] / model.instalmentCout;
                        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, itype, id) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)",chargeid,booksId,@"11",model.cardId,@(poundageMoney),[billdate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,SSJChargeIdTypeRepayment,model.repaymentId]) {
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
                if ([db executeUpdate:@"update bk_user_charge set operatortype = 2 , iversion = ?, cwritedate = ? where id = ? and itype = ?",model.repaymentId,SSJChargeIdTypeRepayment]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                }
                for (int i = 0; i < model.instalmentCout; i ++) {
                    NSString *chargeid = SSJUUID();
                    NSDate *billdate = [NSDate dateWithString:model.applyDate formatString:@"yyyy-MM-dd"];
                    billdate = [billdate dateByAddingMonths:i];
                    if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, itype, id) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)",chargeid,booksId,@"11",model.cardId,model.repaymentMoney,[billdate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,SSJChargeIdTypeRepayment,model.repaymentId]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                    }
                    if (model.poundageRate) {
                        float poundageMoney = [model.repaymentMoney doubleValue] * [model.poundageRate doubleValue] / model.instalmentCout;
                        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cbooksid, ibillid, ifunsid, imoney, cbilldate, cmemo, cuserid, iversion, operatortype, cwritedate, itype, id) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)",chargeid,booksId,@"11",model.cardId,@(poundageMoney),[billdate formattedDateWithFormat:@"yyyy-MM-dd"],model.memo,userID,@(SSJSyncVersion()),writeDate,SSJChargeIdTypeRepayment,model.repaymentId]) {
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
    }];
}
@end
