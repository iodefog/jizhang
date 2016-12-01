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
            }else{
                //是还款的情况
                NSString *fundParent = [db stringForQuery:@"select cparent from bk_fund_info where cfundid = ?",item.fundId];
                if ([fundParent isEqualToString:@"3"]) {
                    model.cardId = item.fundId;
                    model.repaymentSourceFoundId = [db stringForQuery:@"select ifunsid from bk_user_charge where cwritedate = ? and ichargeid <> ? and itype = ?",item.editeDate,item.ID,SSJChargeIdTypeRepayment];
                    model.repaymentSourceFoundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",model.repaymentSourceFoundId];
                } else{
                    model.cardId = [db stringForQuery:@"select ifunsid from bk_user_charge where cwritedate = ? and ichargeid <> ? and itype = ?",item.editeDate,item.ID,SSJChargeIdTypeRepayment];
                    model.repaymentSourceFoundId = item.fundId;
                    model.repaymentSourceFoundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",item.fundId];
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
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
       
    }];
}
@end
