//
//  SSJFundingDetailHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//


#import "SSJFundingDetailHelper.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJFundingListDayItem.h"
#import "SSJCreditCardListDetailItem.h"

NSString *const SSJFundingDetailDateKey = @"SSJFundingDetailDateKey";
NSString *const SSJFundingDetailRecordKey = @"SSJFundingDetailRecordKey";
NSString *const SSJFundingDetailSumKey = @"SSJFundingDetailSumKey";


@implementation SSJFundingDetailHelper

+ (void)queryDataWithFundTypeID:(NSString *)ID
                         success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data,SSJFinancingHomeitem *fundingItem))success
                         failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        SSJFinancingHomeitem *fundingItem = [[SSJFinancingHomeitem alloc]init];
        NSString *userid = SSJUSERID();
        NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
        NSString *sql = [NSString stringWithFormat:@"select substr(a.cbilldate,0,7) as cmonth , a.* , a.cwritedate as chargedate , a.id as sundryid, b.*, c.lender, c.itype as loantype from BK_USER_CHARGE a, BK_BILL_TYPE b left join bk_loan c on a.loanid = c.loanid where a.IBILLID = b.ID and a.IFUNSID = '%@' and a.operatortype <> 2 and (a.cbilldate <= '%@' or length(a.loanid) > 0) order by cmonth desc , a.cbilldate desc , a.cwritedate desc", ID , [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
        FMResultSet *resultSet = [db executeQuery:sql];
        if (!resultSet) {
            if (failure) {
                failure([db lastError]);
            }
        }
        NSMutableArray *result = [NSMutableArray array];
        NSString *lastDate = @"";
        NSString *lastDetailDate = @"";
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [resultSet boolForColumn:@"ITYPE"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.editeDate = [resultSet stringForColumn:@"chargedate"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.configId = [resultSet stringForColumn:@"iconfigid"];
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.loanId = [resultSet stringForColumn:@"loanid"];
            item.loanId = [resultSet stringForColumn:@"loanid"];
            item.loanSource = [resultSet stringForColumn:@"lender"];
            item.loanType = [resultSet intForColumn:@"loantype"];
            item.idType = [resultSet intForColumn:@"ichargetype"];
            item.sundryId = [resultSet stringForColumn:@"sundryid"];
            if (item.incomeOrExpence) {
                if (![item.money hasPrefix:@"-"]) {
                    item.money = [NSString stringWithFormat:@"-%.2f",[item.money doubleValue]];
                }
                fundingItem.fundingExpence = fundingItem.fundingExpence + [item.money doubleValue];
            }else if(!item.incomeOrExpence){
                if (![item.money hasPrefix:@"+"]) {
                    item.money = [NSString stringWithFormat:@"+%.2f",[item.money doubleValue]];
                }
                fundingItem.fundingIncome = fundingItem.fundingIncome + [item.money doubleValue];
            }
            if (item.loanId.length) {
                // 先判断他是借入还是借出
                if (item.loanType == SSJLoanTypeBorrow) {
                    //借入
                    if ([item.typeName isEqualToString:@"转入"]) {
                        // 对于借入来说转入是创建
                        item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
                    }else if ([item.typeName isEqualToString:@"转出"]){
                        // 转出是结清
                        item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
                    }else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]){
                        item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
                    }else if ([item.typeName isEqualToString:@"借贷变更收入"]){
                        // 变更收入是追加
                        item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
                    }else if ([item.typeName isEqualToString:@"借贷变更支出"]){
                        // 变更支出是收款
                        item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
                    }else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]){
                        // 余额转入转出是余额变更
                        item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
                    }
                }else{
                    //借出
                    if ([item.typeName isEqualToString:@"转入"]) {
                        // 对于借入来说转入是结清
                        item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
                    }else if ([item.typeName isEqualToString:@"转出"]){
                        // 转出是创建
                        item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
                    }else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]){
                        item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
                    }else if ([item.typeName isEqualToString:@"借贷变更收入"]){
                        // 变更收入是收款
                        item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
                    }else if ([item.typeName isEqualToString:@"借贷变更支出"]){
                        // 变更支出是追加
                        item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
                    }else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]){
                        // 余额转入转出是余额变更
                        item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
                    }
                }
            }else{
                if ([item.typeName isEqualToString:@"转入"]) {
                    item.transferSource = [db stringForQuery:@"select b.cacctname from bk_user_charge as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '4' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
                }else if ([item.typeName isEqualToString:@"转出"]){
                    item.transferSource = [db stringForQuery:@"select b.cacctname from bk_user_charge as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.cuserid = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '3' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
                }
            }
            NSString *month = [resultSet stringForColumn:@"cmonth"];
            if ([month isEqualToString:lastDate]) {
                SSJFundingDetailListItem *listItem = [result lastObject];
                if (item.incomeOrExpence) {
                    listItem.expenture = listItem.expenture - [item.money doubleValue];
                }else{
                    listItem.income = listItem.income + [item.money doubleValue]; 
                }
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    SSJFundingListDayItem *dayItem = [tempDateArr firstObject];
                    if (item.incomeOrExpence) {
                        dayItem.expenture = dayItem.expenture - [item.money doubleValue];
                    }else{
                        dayItem.income = dayItem.income + [item.money doubleValue];
                    }
                    [tempDateArr addObject:item];
                }else{
                    [listItem.chargeArray addObjectsFromArray:tempDateArr];
                    [tempDateArr removeAllObjects];
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                    dayItem.date = item.billDate;
                    if (item.incomeOrExpence) {
                        dayItem.expenture = - [item.money doubleValue];
                    }else{
                        dayItem.income = [item.money doubleValue];
                    }
                    lastDetailDate = item.billDate;
                    [tempDateArr addObject:dayItem];
                    [tempDateArr addObject:item];
                }
            } else{
                SSJFundingDetailListItem *lastlistItem = [result lastObject];
                [lastlistItem.chargeArray addObjectsFromArray:tempDateArr];
                [tempDateArr removeAllObjects];
                SSJFundingDetailListItem *listItem = [[SSJFundingDetailListItem alloc]init];
                if ([lastDate isEqualToString:@""]) {
                    listItem.isExpand = YES;
                }else{
                    listItem.isExpand = NO;
                }
                if (item.incomeOrExpence) {
                    listItem.expenture = - [item.money doubleValue];
                }else{
                    listItem.income = [item.money doubleValue];
                }
                listItem.date = month;
                SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                dayItem.date = item.billDate;
                if (item.incomeOrExpence) {
                    dayItem.expenture = - [item.money doubleValue];
                }else{
                    dayItem.income = [item.money doubleValue];
                }
                listItem.chargeArray = [NSMutableArray arrayWithCapacity:0];
                lastDetailDate = item.billDate;
                [tempDateArr addObject:dayItem];
                [tempDateArr addObject:item];
                lastDate = month;
                [result addObject:listItem];
            }
        }
        SSJFundingDetailListItem *listItem = [result lastObject];
        [listItem.chargeArray addObjectsFromArray:tempDateArr];
        [resultSet close];
        fundingItem.fundingName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ? and cuserid = ?",ID,userid];
        fundingItem.fundingColor = [db stringForQuery:@"select ccolor from bk_fund_info where cfundid = ? and cuserid = ?",ID,userid];
        SSJDispatchMainAsync(^{
            if (success) {
                success(result,fundingItem);
            }
        });
    }];
}

+ (void)queryDataWithCreditCardItem:(SSJCreditCardItem *)cardItem
                        success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data,SSJCreditCardItem *cardItem))success
                        failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *sql = [NSString stringWithFormat:@"select a.* , a.cwritedate as chargedate, a.id as sundryid, c.lender, c.itype as loantype, b.*  from BK_USER_CHARGE a, BK_BILL_TYPE b left join bk_loan c on a.loanid = c.loanid where a.IBILLID = b.ID and a.IFUNSID = '%@' and a.operatortype <> 2 and a.cbilldate <= '%@' order by a.cbilldate desc ,  a.cwritedate desc", cardItem.cardId , [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
        FMResultSet *resultSet = [db executeQuery:sql];
        SSJCreditCardItem *newcardItem = [[SSJCreditCardItem alloc]init];
        if (!resultSet) {
            if (failure) {
                failure([db lastError]);
            }
        }
        NSMutableArray *result = [NSMutableArray array];
        NSString *lastPeriod = @"";
        NSString *lastDetailDate = @"";
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [resultSet boolForColumn:@"ITYPE"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.editeDate = [resultSet stringForColumn:@"chargedate"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.configId = [resultSet stringForColumn:@"iconfigid"];
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            item.loanId = [resultSet stringForColumn:@"loanid"];
            item.loanSource = [resultSet stringForColumn:@"lender"];
            item.loanType = [resultSet intForColumn:@"loantype"];
            item.idType = [resultSet intForColumn:@"ichargetype"];
            item.sundryId = [resultSet stringForColumn:@"sundryid"];
            item.money = [resultSet stringForColumn:@"imoney"];
            if (item.incomeOrExpence) {
                if (![item.money hasPrefix:@"-"]) {
                    item.money = [NSString stringWithFormat:@"-%.2f",[item.money doubleValue]];
                }
                newcardItem.cardExpence = newcardItem.cardExpence + [item.money doubleValue];
            }else if(!item.incomeOrExpence){
                if (![item.money hasPrefix:@"+"]) {
                    item.money = [NSString stringWithFormat:@"+%.2f",[item.money doubleValue]];
                }
                newcardItem.cardIncome = newcardItem.cardIncome + [item.money doubleValue];
            }
            if (item.loanId.length) {
                // 先判断他是借入还是借出
                if (item.loanType) {
                    //借入
                    if ([item.typeName isEqualToString:@"转入"]) {
                        // 对于借入来说转入是创建
                        item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
                    }else if ([item.typeName isEqualToString:@"转出"]){
                        // 转出是结清
                        item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
                    }else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]){
                        item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
                    }else if ([item.typeName isEqualToString:@"借贷变更收入"]){
                        // 变更收入是追加
                        item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
                    }else if ([item.typeName isEqualToString:@"借贷变更支出"]){
                        // 变更支出是收款
                        item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
                    }else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]){
                        // 余额转入转出是余额变更
                        item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
                    }
                }else{
                    //借出
                    if ([item.typeName isEqualToString:@"转入"]) {
                        // 对于借入来说转入是结清
                        item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
                    }else if ([item.typeName isEqualToString:@"转出"]){
                        // 转出是创建
                        item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
                    }else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]){
                        item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
                    }else if ([item.typeName isEqualToString:@"借贷变更收入"]){
                        // 变更收入是收款
                        item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
                    }else if ([item.typeName isEqualToString:@"借贷变更支出"]){
                        // 变更支出是追加
                        item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
                    }else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]){
                        // 余额转入转出是余额变更
                        item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
                    }
                }
            }else{
                if ([item.typeName isEqualToString:@"转入"]) {
                    item.transferSource = [db stringForQuery:@"select b.cacctname from bk_user_charge as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '4' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
                }else if ([item.typeName isEqualToString:@"转出"]){
                    item.transferSource = [db stringForQuery:@"select b.cacctname from bk_user_charge as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.cuserid = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '3' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
                }
            }

            NSDate *billDate = [NSDate dateWithString:item.billDate formatString:@"yyyy-MM-dd"];
            NSString *currentPeriod;
            NSString *currentMonth;
            if (billDate.day >= cardItem.cardBillingDay) {
                NSDate *firstDate = [[NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay] dateByAddingDays:1];
                NSDate *secondDate = [[NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay] dateByAddingMonths:1];
                currentPeriod = [NSString stringWithFormat:@"%d.%d-%d.%d",firstDate.month,firstDate.day,secondDate.month,secondDate.day];
                currentMonth = [[[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] dateByAddingMonths:1] formattedDateWithFormat:@"yyyy-MM"];
            }else{
                NSDate *firstDate = [[[NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay] dateByAddingDays:1] dateBySubtractingMonths:1];
                NSDate *secondDate = [NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay];
                currentPeriod = [NSString stringWithFormat:@"%d.%d-%d.%d",firstDate.month,firstDate.day,secondDate.month,secondDate.day];
                currentMonth = [[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] formattedDateWithFormat:@"yyyy-MM"];
            }
            if ([currentPeriod isEqualToString:lastPeriod]) {
                SSJCreditCardListDetailItem *listItem = [result lastObject];
                if (item.incomeOrExpence) {
                    listItem.expenture = listItem.expenture - [item.money doubleValue];
                }else{
                    listItem.income = listItem.income + [item.money doubleValue];
                }
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    [listItem.chargeArray addObject:item];
                }else{
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                    dayItem.date = item.billDate;
                    NSString *incomeSql = [NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a , bk_bill_type as b where ifunsid = '%@' and a.ibillid = b.id and b.itype = 0 and a.cbilldate = '%@' and operatortype <> 2",cardItem.cardId,item.billDate];
                    NSString *expenceSql = [NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a , bk_bill_type as b where ifunsid = '%@' and a.ibillid = b.id and b.itype = 1 and a.cbilldate = '%@' and operatortype <> 2",cardItem.cardId,item.billDate];
                    dayItem.income = [db doubleForQuery:incomeSql];
                    dayItem.expenture = [db doubleForQuery:expenceSql];
                    lastDetailDate = item.billDate;
                    [listItem.chargeArray addObject:dayItem];
                    [listItem.chargeArray addObject:item];
                }
            }else{
                SSJCreditCardListDetailItem *listItem = [[SSJCreditCardListDetailItem alloc]init];
                listItem.billingDay = cardItem.cardBillingDay;
                listItem.repaymentDay = cardItem.cardRepaymentDay;
                listItem.month = currentMonth;
                if (result.count < 2) {
                    listItem.isExpand = YES;
                }else{
                    listItem.isExpand = NO;
                }
                if (item.incomeOrExpence) {
                    listItem.expenture = - [item.money doubleValue];
                }else{
                    listItem.income = [item.money doubleValue];
                }
                listItem.datePeriod = currentPeriod;
                NSMutableArray *tempArray = [NSMutableArray array];
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    [tempArray addObject:item];
                }else{
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                    dayItem.date = item.billDate;
                    NSString *incomeSql = [NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a , bk_bill_type as b where ifunsid = '%@' and a.ibillid = b.id and b.itype = 0 and a.cbilldate = '%@' and operatortype <> 2",cardItem.cardId,item.billDate];
                    NSString *expenceSql = [NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a , bk_bill_type as b where ifunsid = '%@' and a.ibillid = b.id and b.itype = 1 and a.cbilldate = '%@' and operatortype <> 2",cardItem.cardId,item.billDate];
                    dayItem.income = [db doubleForQuery:incomeSql];
                    dayItem.expenture = [db doubleForQuery:expenceSql];
                    lastDetailDate = item.billDate;
                    [tempArray addObject:dayItem];
                    [tempArray addObject:item];
                }
                listItem.chargeArray = [NSMutableArray arrayWithArray:tempArray];
                lastPeriod = currentPeriod;
                [result addObject:listItem];
            }
        }
        [resultSet close];
        newcardItem.cardColor = [db stringForQuery:@"select ccolor from bk_fund_info where cfundid = ? and cuserid = ?",cardItem.cardId,userid];
        newcardItem.cardName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ? and cuserid = ?",cardItem.cardId,userid];
        SSJDispatchMainAsync(^{
            if (success) {
                success(result,newcardItem);
            }
        });
    }];
}

+ (BOOL)queryCloseOutStateWithLoanId:(NSString *)loanId {
    __block BOOL closeOut = NO;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        closeOut = [db boolForQuery:@"select iend from bk_loan where loanid = ?", loanId];
    }];
    return closeOut;
}


+ (NSString *)stringFromWeekday:(NSInteger)weekday {
    switch (weekday) {
        case 1: return @"星期日";
        case 2: return @"星期一";
        case 3: return @"星期二";
        case 4: return @"星期三";
        case 5: return @"星期四";
        case 6: return @"星期五";
        case 7: return @"星期六";

        default: return nil;
    }
}


@end
