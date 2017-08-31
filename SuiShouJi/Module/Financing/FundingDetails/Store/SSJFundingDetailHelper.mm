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
#import "SSJOrmDatabaseQueue.h"
#import "SSJFundInfoTable.h"
#import "SSJUserCreditTable.h"
#import "SSJUserChargeTable.h"
#import "SSJUserBillTypeTable.h"
#import "SSJShareBooksMemberTable.h"
#import "SSJUserRemindTable.h"
#import "SSJLoanTable.h"
#import "SSJCreditRepaymentTable.h"

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
        NSString *sql = [NSString stringWithFormat:@"select substr(a.cbilldate,1,7) as cmonth , a.* , a.cwritedate as chargedate , a.cid as sundryid, b.cicoin, b.cname, b.ccolor, b.itype, c.lender, c.itype as loantype from BK_USER_CHARGE a, BK_USER_BILL_TYPE b left join BK_LOAN c on a.cid = c.loanid left join BK_SHARE_BOOKS_MEMBER d on d.cbooksid = a.cbooksid and d.cmemberid = a.cuserid where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.IFUNSID = '%@' and a.operatortype <> 2 and (a.cbilldate <= '%@' or (length(a.cid) > 0 and a.ichargetype = %ld)) and (d.istate = %d or d.istate is null or a.ibillid in ('13','14')) order by cmonth desc ,a.cbilldate desc ,a.cwritedate desc", ID , [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"],(long)SSJChargeIdTypeLoan, (int)SSJShareBooksMemberStateNormal];
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
            item.imageName = [resultSet stringForColumn:@"CICOIN"];
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
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.loanSource = [resultSet stringForColumn:@"lender"];
            item.loanType = (SSJLoanType)[resultSet intForColumn:@"loantype"];
            item.idType = (SSJChargeIdType)[resultSet intForColumn:@"ichargetype"];
            double money = [item.money doubleValue];
            item.sundryId = [resultSet stringForColumn:@"sundryid"];
            if (item.incomeOrExpence) {
                item.money = [NSString stringWithFormat:@"-%.2f",money];
                fundingItem.fundingExpence = fundingItem.fundingExpence + money;
            }else if(!item.incomeOrExpence){
                item.money = [NSString stringWithFormat:@"+%.2f",money];
                fundingItem.fundingIncome = fundingItem.fundingIncome + money;
            }
            if (item.idType == SSJChargeIdTypeLoan && item.sundryId.length) {
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
                    item.transferSource = [db stringForQuery:@"select b.cacctname from BK_USER_CHARGE as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.cuserid = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '4' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
                }else if ([item.typeName isEqualToString:@"转出"]){
                    item.transferSource = [db stringForQuery:@"select b.cacctname from BK_USER_CHARGE as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.cuserid = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '3' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
                }
            }
            NSString *month = [resultSet stringForColumn:@"cmonth"];
            if ([month isEqualToString:lastDate]) {
                SSJFundingDetailListItem *listItem = [result lastObject];
                if (item.incomeOrExpence) {
                    listItem.expenture = listItem.expenture + money;
                }else{
                    listItem.income = listItem.income + money;
                }
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    SSJFundingListDayItem *dayItem = [tempDateArr firstObject];
                    if (item.incomeOrExpence) {
                        dayItem.expenture = dayItem.expenture + money;
                    }else{
                        dayItem.income = dayItem.income + money;
                    }
                    [tempDateArr addObject:item];
                }else{
                    [listItem.chargeArray addObjectsFromArray:tempDateArr];
                    [tempDateArr removeAllObjects];
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                    dayItem.date = item.billDate;
                    if (item.incomeOrExpence) {
                        dayItem.expenture = money;
                    }else{
                        dayItem.income = money;
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
                    listItem.expenture = money;
                }else{
                    listItem.income = money;
                }
                listItem.date = month;
                SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                dayItem.date = item.billDate;
                if (item.incomeOrExpence) {
                    dayItem.expenture = money;
                }else{
                    dayItem.income = money;
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
        fundingItem.startColor = [db stringForQuery:@"select cstartcolor from bk_fund_info where cfundid = ? and cuserid = ?",ID,userid];
        fundingItem.endColor = [db stringForQuery:@"select cendcolor from bk_fund_info where cfundid = ? and cuserid = ?",ID,userid];
        dispatch_main_async_safe (^{
            if (success) {
                success(result,fundingItem);
            }
        });
    }];
}

+ (void)queryDataWithCreditCardId:(NSString *)cardId
                        success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data,SSJFinancingHomeitem *cardItem))success
                        failure:(void (^)(NSError *error))failure{
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        SSJFinancingHomeitem *newItem = [self getFundingItemWithFundId:cardId inDataBase:db];
        
        NSString *userId = SSJUSERID();

        WCTResultList resultList;
        
        for (const WCTProperty& property : SSJUserChargeTable.AllProperties) {
            resultList.push_back(property.inTable(@"BK_USER_CHARGE"));
        }
        for (const WCTProperty& property : SSJUserBillTypeTable.AllProperties) {
            resultList.push_back(property.inTable(@"BK_USER_BILL_TYPE"));
        }
        for (const WCTProperty& property : SSJShareBooksMemberTable.AllProperties) {
            resultList.push_back(property.inTable(@"BK_SHARE_BOOKS_MEMBER"));
        }
        for (const WCTProperty& property : SSJLoanTable.AllProperties) {
            resultList.push_back(property.inTable(@"BK_LOAN"));
        }

        WCDB::JoinClause joinClause = WCDB::JoinClause("BK_USER_CHARGE").join("BK_USER_BILL_TYPE", WCDB::JoinClause::Type::Inner).
                on(SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.billId.inTable(@"BK_USER_BILL_TYPE")
                   && ((SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.booksId.inTable(@"BK_USER_BILL_TYPE")
                        && SSJUserChargeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.userId.inTable(@"BK_USER_BILL_TYPE"))
                       || SSJUserBillTypeTable.billId.length() < 4)
                   && SSJUserBillTypeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUSERID ()
                   && SSJUserChargeTable.operatorType.inTable(@"BK_USER_CHARGE") != 2
                   && SSJUserChargeTable.fundId == cardId);

        joinClause.join("BK_SHARE_BOOKS_MEMBER", WCDB::JoinClause::Type::Left).
                on(SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJShareBooksMemberTable.booksId.inTable(@"BK_SHARE_BOOKS_MEMBER"));

        joinClause.join("BK_LOAN", WCDB::JoinClause::Type::Left).
                on(SSJUserChargeTable.cid.inTable(@"BK_USER_CHARGE") == SSJLoanTable.loanId.inTable(@"BK_LOAN"));

        WCDB::StatementSelect statementSelect = WCDB::StatementSelect().select(resultList).from(joinClause).
                where(SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER") == SSJShareBooksMemberStateNormal
                      || SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER").isNull()
                      || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"13"
                      || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"14");

        WCTStatement *statement = [db prepare:statementSelect];

        NSMutableArray *result = [NSMutableArray array];
        NSString *lastPeriod = @"";
        NSString *lastDetailDate = @"";
        SSJFundingListDayItem *lastDayItem;
        
        if ([statement getError]) {
            dispatch_main_async_safe(^{
                if (failure) {
                    failure([statement getError]);
                }
            });
        }
        
        NSMutableArray *chargeArr = [NSMutableArray arrayWithCapacity:0];

        while ( [statement step] ) {
            SSJBillingChargeCellItem *chargeItem = [self getChargeItemWithStatement:statement];
            [chargeArr addObject:chargeItem];
            NSLog(@"%@",[chargeItem ssj_debugDescription]);
        }
        
        for (SSJBillingChargeCellItem *item in chargeArr) {
            double money = [item.money doubleValue];
            if (item.idType == SSJChargeIdTypeLoan && item.sundryId.length) {
                // 先判断他是借入还是借出
                switch (item.loanType) {
                    case SSJLoanTypeLend:
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
                        break;
                        
                    case SSJLoanTypeBorrow:
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
                        break;
                }
            } else {
                if ([item.billId isEqualToString:@"3"]) {
                    NSString *sourceId = [db getOneValueOnResult:SSJUserChargeTable.fundId
                                                       fromTable:@"bk_user_charge"
                                                           where:SSJUserChargeTable.cid == item.sundryId
                                                                 && SSJUserChargeTable.userId == userId
                                                                 && SSJUserChargeTable.billId == @"4"];
                    item.transferSource = [db getOneValueOnResult:SSJFundInfoTable.fundName
                                                        fromTable:@"bk_fund_info"
                                                            where:SSJFundInfoTable.fundId == sourceId];
                }else if ([item.billId isEqualToString:@"4"]) {
                    NSString *sourceId = [db getOneValueOnResult:SSJUserChargeTable.fundId
                                                       fromTable:@"bk_user_charge"
                                                           where:SSJUserChargeTable.cid == item.sundryId
                                                                 && SSJUserChargeTable.userId == userId
                                                                 && SSJUserChargeTable.billId == @"3"];
                    item.transferSource = [db getOneValueOnResult:SSJFundInfoTable.fundName
                                                        fromTable:@"bk_fund_info"
                                                            where:SSJFundInfoTable.fundId == sourceId];
                }

            }
            NSDate *billDate = [NSDate dateWithString:item.billDate formatString:@"yyyy-MM-dd"];
            NSString *currentPeriod;
            NSString *currentMonth;
            if (billDate.day >= newItem.cardItem.cardBillingDay) {
                if (newItem.cardItem.cardType == SSJCrediteCardTypeAlipay) {
                    NSDate *firstDate = [NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay];
                    NSDate *secondDate = [[[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateByAddingMonths:1] dateBySubtractingDays:1];
                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",(long)firstDate.month,(long)firstDate.day,(long)secondDate.month,(long)secondDate.day];
                    currentMonth = [[[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] dateByAddingMonths:1] formattedDateWithFormat:@"yyyy-MM"];
                    
                } else {
                    NSDate *firstDate = [[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateByAddingDays:1];
                    NSDate *secondDate = [[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateByAddingMonths:1];
                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",(long)firstDate.month,(long)firstDate.day,(long)secondDate.month,(long)secondDate.day];
                    currentMonth = [[[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] dateByAddingMonths:1] formattedDateWithFormat:@"yyyy-MM"];
                    
                }
            }else{
                if (newItem.cardItem.cardType == SSJCrediteCardTypeAlipay) {
                    NSDate *firstDate = [[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateBySubtractingMonths:1];
                    NSDate *secondDate = [[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateBySubtractingDays:1];
                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",(long)firstDate.month,(long)firstDate.day,(long)secondDate.month,(long)secondDate.day];
                    currentMonth = [[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] formattedDateWithFormat:@"yyyy-MM"];
                } else {
                    NSDate *firstDate = [[[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateByAddingDays:1] dateBySubtractingMonths:1];
                    NSDate *secondDate = [NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay];
                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",(long)firstDate.month,(long)firstDate.day,(long)secondDate.month,(long)secondDate.day];
                    currentMonth = [[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] formattedDateWithFormat:@"yyyy-MM"];
                }
            }
            if ([currentPeriod isEqualToString:lastPeriod]) {
                SSJCreditCardListDetailItem *listItem = [result lastObject];
                if (item.incomeOrExpence) {
                    listItem.expenture = listItem.expenture + money;
                }else{
                    listItem.income = listItem.income + money;
                }
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    [listItem.chargeArray addObject:item];
                    if (item.incomeOrExpence) {
                        lastDayItem.expenture = lastDayItem.expenture + money;
                    } else {
                        lastDayItem.income = lastDayItem.income + money;
                    }
                }else{
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                    lastDayItem = dayItem;
                    dayItem.date = item.billDate;
                    if (item.incomeOrExpence) {
                        dayItem.expenture = dayItem.expenture + money;
                    } else {
                        dayItem.income = dayItem.income + money;
                    }
                    lastDetailDate = item.billDate;
                    [listItem.chargeArray addObject:dayItem];
                    [listItem.chargeArray addObject:item];
                }
            }else{
                SSJCreditCardListDetailItem *listItem = [[SSJCreditCardListDetailItem alloc]init];
                listItem.month = currentMonth;
                listItem.billingDay = newItem.cardItem.cardBillingDay;
                listItem.repaymentDay = newItem.cardItem.cardRepaymentDay;
                listItem.instalmentMoney = [[db getOneValueOnResult:SSJCreditRepaymentTable.repaymentMoney
                                                         fromTable:@"bk_credit_repayment"
                                                             where:SSJCreditRepaymentTable.userId == userId
                                                                   && SSJCreditRepaymentTable.repaymentMonth == listItem.month
                                                                   && SSJCreditRepaymentTable.operatorType == 2
                                                                   && SSJCreditRepaymentTable.cardId == cardId
                                                                   && SSJCreditRepaymentTable.instalmentCount > 0] doubleValue];
                listItem.repaymentMoney = [[db getOneValueOnResult:SSJCreditRepaymentTable.repaymentMoney.sum()
                                                        fromTable:@"bk_credit_repayment"
                                                            where:SSJCreditRepaymentTable.userId == userId
                                                                  && SSJCreditRepaymentTable.repaymentMonth == listItem.month
                                                                  && SSJCreditRepaymentTable.cardId == cardId
                                                                  && SSJCreditRepaymentTable.operatorType == 2
                                                                  && SSJCreditRepaymentTable.instalmentCount = 0] doubleValue];
                NSDate *currentMonth = [NSDate dateWithString:listItem.month formatString:@"yyyy-MM"];
                NSDate *firstDate = [[NSDate dateWithYear:currentMonth.year month:currentMonth.month day:newItem.cardItem.cardBillingDay] dateBySubtractingMonths:1];
                NSDate *seconDate = [[NSDate dateWithYear:currentMonth.year month:currentMonth.month day:newItem.cardItem.cardBillingDay] dateByAddingDays:1];
                listItem.repaymentForOtherMonthMoney = [[db getOneValueOnResult:SSJCreditRepaymentTable.repaymentMoney.sum()
                                                                      fromTable:@"bk_credit_repayment"
                                                                          where:SSJCreditRepaymentTable.userId == userId
                                                                                && SSJCreditRepaymentTable.repaymentMonth == listItem.month
                                                                                && SSJCreditRepaymentTable.cardId == cardId
                                                                                && SSJCreditRepaymentTable.operatorType == 2
                                                                                && SSJCreditRepaymentTable.instalmentCount == 0
                                                                                && SSJCreditRepaymentTable.applyDate.between ([firstDate formattedDateWithFormat:@"yyyy-MM-dd"],[seconDate formattedDateWithFormat:@"yyyy-MM-dd"])]
                                                            doubleValue];
                if (result.count < 2) {
                    listItem.isExpand = YES;
                }else{
                    listItem.isExpand = NO;
                }
                if (item.incomeOrExpence) {
                    listItem.expenture = money;
                }else{
                    listItem.income = money;
                }
                listItem.datePeriod = currentPeriod;
                NSMutableArray *tempArray = [NSMutableArray array];
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    if (item.incomeOrExpence) {
                        lastDayItem.expenture = lastDayItem.expenture + money;
                    } else {
                        lastDayItem.income = lastDayItem.income + money;
                    }
                    [tempArray addObject:item];
                }else{
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                    lastDayItem = dayItem;
                    dayItem.date = item.billDate;
                    if (item.incomeOrExpence) {
                        dayItem.expenture = dayItem.expenture + money;
                    } else {
                        dayItem.income = dayItem.income + money;
                    }
                    lastDetailDate = item.billDate;
                    [tempArray addObject:dayItem];
                    [tempArray addObject:item];
                }
                listItem.chargeArray = [NSMutableArray arrayWithArray:tempArray];
                lastPeriod = currentPeriod;
                [result addObject:listItem];
            }

        }

//        NSString *sql = [NSString stringWithFormat:@"select a.* , a.cwritedate as chargedate, a.cid as sundryid, c.lender, c.itype as loantype, b.cicoin, b.cname, b.ccolor, b.itype from BK_USER_CHARGE a, BK_USER_BILL_TYPE b left join BK_LOAN c on a.cid = c.loanid left join BK_SHARE_BOOKS_MEMBER d on d.cbooksid = a.cbooksid and d.cmemberid = a.cuserid where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.ifunsid = '%@' and a.operatortype <> 2 and (a.cbilldate <= '%@' or (length(a.cid) > 0 and a.ichargetype = %ld)) and (d.istate = %d or d.istate is null or a.ibillid in ('13','14')) order by a.cbilldate desc ,  a.cwritedate desc", cardItem.fundingID , [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"],(long)SSJChargeIdTypeLoan,(int)SSJShareBooksMemberStateNormal];
//        FMResultSet *resultSet = [db executeQuery:sql];
//        SSJCreditCardItem *newcardItem = [[SSJCreditCardItem alloc]init];
//        if (!resultSet) {
//            if (failure) {
//                failure([db lastError]);
//            }
//        }

//        while ([resultSet next]) {
//            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
//            item.imageName = [resultSet stringForColumn:@"CICOIN"];
//            item.typeName = [resultSet stringForColumn:@"CNAME"];
//            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
//            item.incomeOrExpence = [resultSet boolForColumn:@"ITYPE"];
//            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
//            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
//            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
//            item.editeDate = [resultSet stringForColumn:@"chargedate"];
//            item.billId = [resultSet stringForColumn:@"IBILLID"];
//            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
//            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
//            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
//            item.booksId = [resultSet stringForColumn:@"cbooksid"];
//            item.loanSource = [resultSet stringForColumn:@"lender"];
//            item.loanType = (SSJLoanType)[resultSet intForColumn:@"loantype"];
//            item.idType = (SSJChargeIdType)[resultSet intForColumn:@"ichargetype"];
//            item.sundryId = [resultSet stringForColumn:@"sundryid"];
//            item.money = [resultSet stringForColumn:@"imoney"];
//            item.fundParent = @"3";
//            double money = [item.money doubleValue];
//            if (item.incomeOrExpence) {
//                item.money = [NSString stringWithFormat:@"-%.2f",money];
//                newcardItem.cardExpence = newcardItem.cardExpence + money;
//            }else if(!item.incomeOrExpence){
//                item.money = [NSString stringWithFormat:@"+%.2f",money];
//                newcardItem.cardIncome = newcardItem.cardIncome + money;
//            }
//
//            if (item.idType == SSJChargeIdTypeLoan && item.sundryId.length) {
//                // 先判断他是借入还是借出
//                switch (item.loanType) {
//                    case SSJLoanTypeLend:
//                        //借出
//                        if ([item.typeName isEqualToString:@"转入"]) {
//                            // 对于借入来说转入是结清
//                            item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
//                        }else if ([item.typeName isEqualToString:@"转出"]){
//                            // 转出是创建
//                            item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
//                        }else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]){
//                            item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
//                        }else if ([item.typeName isEqualToString:@"借贷变更收入"]){
//                            // 变更收入是收款
//                            item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
//                        }else if ([item.typeName isEqualToString:@"借贷变更支出"]){
//                            // 变更支出是追加
//                            item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
//                        }else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]){
//                            // 余额转入转出是余额变更
//                            item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
//                        }
//                        break;
//
//                    case SSJLoanTypeBorrow:
//                        //借入
//                        if ([item.typeName isEqualToString:@"转入"]) {
//                            // 对于借入来说转入是创建
//                            item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
//                        }else if ([item.typeName isEqualToString:@"转出"]){
//                            // 转出是结清
//                            item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
//                        }else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]){
//                            item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
//                        }else if ([item.typeName isEqualToString:@"借贷变更收入"]){
//                            // 变更收入是追加
//                            item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
//                        }else if ([item.typeName isEqualToString:@"借贷变更支出"]){
//                            // 变更支出是收款
//                            item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
//                        }else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]){
//                            // 余额转入转出是余额变更
//                            item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
//                        }
//                        break;
//                }
//            }else{
//                if ([item.typeName isEqualToString:@"转入"]) {
//                    item.transferSource = [db stringForQuery:@"select b.cacctname from BK_USER_CHARGE as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '4' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
//                }else if ([item.typeName isEqualToString:@"转出"]){
//                    item.transferSource = [db stringForQuery:@"select b.cacctname from BK_USER_CHARGE as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.cuserid = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '3' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
//                }
//            }
//            NSDate *billDate = [NSDate dateWithString:item.billDate formatString:@"yyyy-MM-dd"];
//            NSString *currentPeriod;
//            NSString *currentMonth;
//            if (billDate.day >= cardItem.cardBillingDay) {
//                if (cardItem.cardType == SSJCrediteCardTypeAlipay) {
//                    NSDate *firstDate = [NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay];
//                    NSDate *secondDate = [[[NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay] dateByAddingMonths:1] dateBySubtractingDays:1];
//                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",(long)firstDate.month,(long)firstDate.day,(long)secondDate.month,(long)secondDate.day];
//                    currentMonth = [[[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] dateByAddingMonths:1] formattedDateWithFormat:@"yyyy-MM"];
//
//                } else {
//                    NSDate *firstDate = [[NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay] dateByAddingDays:1];
//                    NSDate *secondDate = [[NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay] dateByAddingMonths:1];
//                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",(long)firstDate.month,(long)firstDate.day,(long)secondDate.month,(long)secondDate.day];
//                    currentMonth = [[[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] dateByAddingMonths:1] formattedDateWithFormat:@"yyyy-MM"];
//
//                }
//            }else{
//                if (cardItem.cardType == SSJCrediteCardTypeAlipay) {
//                    NSDate *firstDate = [[NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay] dateBySubtractingMonths:1];
//                    NSDate *secondDate = [[NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay] dateBySubtractingDays:1];
//                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",(long)firstDate.month,(long)firstDate.day,(long)secondDate.month,(long)secondDate.day];
//                    currentMonth = [[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] formattedDateWithFormat:@"yyyy-MM"];
//                } else {
//                    NSDate *firstDate = [[[NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay] dateByAddingDays:1] dateBySubtractingMonths:1];
//                    NSDate *secondDate = [NSDate dateWithYear:0 month:billDate.month day:cardItem.cardBillingDay];
//                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",(long)firstDate.month,(long)firstDate.day,(long)secondDate.month,(long)secondDate.day];
//                    currentMonth = [[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] formattedDateWithFormat:@"yyyy-MM"];
//                }
//            }
//            if ([currentPeriod isEqualToString:lastPeriod]) {
//                SSJCreditCardListDetailItem *listItem = [result lastObject];
//                if (item.incomeOrExpence) {
//                    listItem.expenture = listItem.expenture + money;
//                }else{
//                    listItem.income = listItem.income + money;
//                }
//                if ([item.billDate isEqualToString:lastDetailDate]) {
//                    [listItem.chargeArray addObject:item];
//                    if (item.incomeOrExpence) {
//                        lastDayItem.expenture = lastDayItem.expenture + money;
//                    } else {
//                        lastDayItem.income = lastDayItem.income + money;
//                    }
//                }else{
//                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
//                    lastDayItem = dayItem;
//                    dayItem.date = item.billDate;
//                    if (item.incomeOrExpence) {
//                        dayItem.expenture = dayItem.expenture + money;
//                    } else {
//                        dayItem.income = dayItem.income + money;
//                    }
//                    lastDetailDate = item.billDate;
//                    [listItem.chargeArray addObject:dayItem];
//                    [listItem.chargeArray addObject:item];
//                }
//            }else{
//                SSJCreditCardListDetailItem *listItem = [[SSJCreditCardListDetailItem alloc]init];
//                listItem.billingDay = cardItem.cardBillingDay;
//                listItem.repaymentDay = cardItem.cardRepaymentDay;
//                listItem.month = currentMonth;
//                if (result.count < 2) {
//                    listItem.isExpand = YES;
//                }else{
//                    listItem.isExpand = NO;
//                }
//                if (item.incomeOrExpence) {
//                    listItem.expenture = money;
//                }else{
//                    listItem.income = money;
//                }
//                listItem.datePeriod = currentPeriod;
//                NSMutableArray *tempArray = [NSMutableArray array];
//                if ([item.billDate isEqualToString:lastDetailDate]) {
//                    if (item.incomeOrExpence) {
//                        lastDayItem.expenture = lastDayItem.expenture + money;
//                    } else {
//                        lastDayItem.income = lastDayItem.income + money;
//                    }
//                    [tempArray addObject:item];
//                }else{
//                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
//                    lastDayItem = dayItem;
//                    dayItem.date = item.billDate;
//                    if (item.incomeOrExpence) {
//                        dayItem.expenture = dayItem.expenture + money;
//                    } else {
//                        dayItem.income = dayItem.income + money;
//                    }
//                    lastDetailDate = item.billDate;
//                    [tempArray addObject:dayItem];
//                    [tempArray addObject:item];
//                }
//                listItem.chargeArray = [NSMutableArray arrayWithArray:tempArray];
//                lastPeriod = currentPeriod;
//                [result addObject:listItem];
//            }
//        }
//        [resultSet close];
//        newcardItem.startColor = [db stringForQuery:@"select cstartcolor from bk_fund_info where cfundid = ? and cuserid = ?",cardItem.fundingID,userid];
//        newcardItem.endColor = [db stringForQuery:@"select cendcolor from bk_fund_info where cfundid = ? and cuserid = ?",cardItem.fundingID,userid];
//        newcardItem.fundingName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ? and cuserid = ?",cardItem.fundingID,userid];
//        newcardItem.cardType = (SSJCrediteCardType)[db boolForQuery:@"select itype from bk_user_credit where cfundid = ? and cuserid = ?",cardItem.fundingID,userid];
//        for (SSJCreditCardListDetailItem *listItem in result) {
//            listItem.instalmentMoney = [db doubleForQuery:@"select repaymentmoney from bk_credit_repayment where cuserid = ? and crepaymentmonth = ? and ccardid = ? and operatortype <> 2 and iinstalmentcount > 0",userid,listItem.month,cardItem.fundingID];
//            listItem.repaymentMoney = [db doubleForQuery:@"select sum(repaymentmoney) from bk_credit_repayment where cuserid = ? and crepaymentmonth = ? and ccardid = ? and operatortype <> 2 and iinstalmentcount = 0",userid,listItem.month,cardItem.fundingID];
//            NSDate *currentMonth = [NSDate dateWithString:listItem.month formatString:@"yyyy-MM"];
//            NSDate *firstDate = [[NSDate dateWithYear:currentMonth.year month:currentMonth.month day:cardItem.cardBillingDay] dateBySubtractingMonths:1];
//            NSDate *seconDate = [[NSDate dateWithYear:currentMonth.year month:currentMonth.month day:cardItem.cardBillingDay] dateByAddingDays:1];
//            listItem.repaymentForOtherMonthMoney = [db doubleForQuery:@"select sum(repaymentmoney) from bk_credit_repayment where cuserid = ? and crepaymentmonth <> ? and ccardid = ? and operatortype <> 2 and iinstalmentcount = 0 and capplydate >= ? and capplydate <= ?",userid,listItem.month,cardItem.fundingID,[firstDate formattedDateWithFormat:@"yyyy-MM-dd"],[seconDate formattedDateWithFormat:@"yyyy-MM-dd"]];
//        }
//        double instalMoney = [db doubleForQuery:@"select sum(repaymentmoney) from bk_credit_repayment where cuserid = ? and ccardid = ? and operatortype <> 2 and iinstalmentcount > 0",userid,cardItem.fundingID];
//        if (instalMoney > 0) {
//            newcardItem.hasMadeInstalment = YES;
//        } else {
//            newcardItem.hasMadeInstalment = NO;
//        }
//        newcardItem.cardExpence = newcardItem.cardExpence - instalMoney;
        dispatch_main_async_safe(^{
            if (success) {
                success(result,newItem);
            }
        });
    }];
}

+ (void)queryDataWithBooksId:(NSString * )booksId
                  FundTypeID:(NSString *)ID
                     success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data))success
                     failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
        NSString *sql = [NSString stringWithFormat:@"select substr(a.cbilldate,1,7) as cmonth , a.* , a.cwritedate as chargedate , a.cid as sundryid, b.cicoin, b.cname, b.ccolor, b.itype from BK_USER_CHARGE a, BK_USER_BILL_TYPE b where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.IFUNSID = '%@' and a.operatortype <> 2 and a.cbooksid  = '%@' and a.cbilldate <= '%@' and a.ibillid <> '13' and a.ibillid <> '14' order by cmonth desc ,a.cbilldate desc ,a.cwritedate desc", ID, booksId, [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
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
            item.imageName = [resultSet stringForColumn:@"CICOIN"];
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
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.idType = (SSJChargeIdType)[resultSet intForColumn:@"ichargetype"];
            double money = [item.money doubleValue];
            item.sundryId = [resultSet stringForColumn:@"sundryid"];
            if (item.incomeOrExpence) {
                item.money = [NSString stringWithFormat:@"-%.2f",money];
            }else if(!item.incomeOrExpence){
                item.money = [NSString stringWithFormat:@"+%.2f",money];
            }
            NSString *month = [resultSet stringForColumn:@"cmonth"];
            if ([month isEqualToString:lastDate]) {
                SSJFundingDetailListItem *listItem = [result lastObject];
                if (item.incomeOrExpence) {
                    listItem.expenture = listItem.expenture + money;
                }else{
                    listItem.income = listItem.income + money;
                }
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    SSJFundingListDayItem *dayItem = [tempDateArr firstObject];
                    if (item.incomeOrExpence) {
                        dayItem.expenture = dayItem.expenture + money;
                    }else{
                        dayItem.income = dayItem.income + money;
                    }
                    [tempDateArr addObject:item];
                }else{
                    [listItem.chargeArray addObjectsFromArray:tempDateArr];
                    [tempDateArr removeAllObjects];
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                    dayItem.date = item.billDate;
                    if (item.incomeOrExpence) {
                        dayItem.expenture = money;
                    }else{
                        dayItem.income = money;
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
                    listItem.expenture = money;
                }else{
                    listItem.income = money;
                }
                listItem.date = month;
                SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                dayItem.date = item.billDate;
                if (item.incomeOrExpence) {
                    dayItem.expenture = money;
                }else{
                    dayItem.income = money;
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

        dispatch_main_async_safe(^{
            if (success) {
                success(result);
            }
        });
    }];
}

+ (BOOL)queryCloseOutStateWithLoanId:(NSString *)loanId {
    __block BOOL closeOut = NO;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        closeOut = [db boolForQuery:@"select iend from BK_LOAN where loanid = ?", loanId];
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


+ (SSJFinancingHomeitem *)getFundingItemWithFundId:(NSString *)fundid inDataBase:(WCTDatabase *)db {
    SSJFundInfoTable *fund = [db getOneObjectOfClass:SSJFundInfoTable.class fromTable:@"bk_fund_info" where:SSJFundInfoTable.fundId == fundid
                                                                                                            && SSJFundInfoTable.userId == SSJUSERID ()];
    SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];

    item.fundingID = fund.fundId;
    item.fundingName = fund.fundName;
    item.fundingMemo = fund.memo;
    item.fundingColor = fund.fundColor;
    item.fundingIcon = fund.fundIcon;
    item.startColor = fund.startColor;
    item.endColor = fund.endColor;

    item.chargeCount = [[db getOneValueOnResult:SSJUserChargeTable.AnyProperty.count() fromTable:@"BK_USER_CHARGE" where:SSJUserChargeTable.userId == SSJUSERID ()
                                                                                                                         && SSJUserChargeTable.operatorType != 2
                                                                                                                         && SSJUserChargeTable.fundId == item.fundingID] doubleValue];

    item.fundingIncome = [[self getFundBalanceWithFundId:item.fundingID type:SSJBillTypeIncome inDataBase:db] doubleValue];

    item.fundingExpence = [[self getFundBalanceWithFundId:item.fundingID type:SSJBillTypePay inDataBase:db] doubleValue];

    item.fundingAmount = item.fundingIncome - item.fundingExpence;

    SSJUserCreditTable *credit = [db getOneObjectOfClass:SSJUserCreditTable.class
                                               fromTable:@"bk_user_credit"
                                                   where:SSJUserCreditTable.cardId == item.fundingID
                                                         && SSJUserCreditTable.userId == SSJUSERID ()];



    if ([item.fundingParent isEqualToString:@"3"] || [item.fundingParent isEqualToString:@""]) {
        SSJCreditCardItem *cardItem = [[SSJCreditCardItem alloc] init];
        cardItem.cardLimit = [credit.cardQuota doubleValue];
        cardItem.settleAtRepaymentDay = credit.billDateSettlement;
        cardItem.cardBillingDay = [credit.billingDate integerValue];
        cardItem.cardRepaymentDay = [credit.repaymentDate integerValue];
        cardItem.remindId = credit.remindId;
        cardItem.remindState = [[db getOneValueOnResult:SSJUserRemindTable.state
                                              fromTable:@"bk_user_remind"
                                                  where:SSJUserRemindTable.remindId == credit.remindId] boolValue];
        item.cardItem = cardItem;
    }

    return item;

}


+ (NSNumber *)getFundBalanceWithFundId:(NSString *)fundId type:(SSJBillType)type inDataBase:(WCTDatabase *)db {
    NSNumber *currentBalance = 0;

    WCTResultList resultList = { SSJUserChargeTable.money.inTable (@"BK_USER_CHARGE").sum()};

    WCDB::JoinClause joinClause = WCDB::JoinClause("BK_USER_CHARGE").join("BK_USER_BILL_TYPE", WCDB::JoinClause::Type::Inner).
            on(SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.billId.inTable(@"BK_USER_BILL_TYPE")
               && ((SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.booksId.inTable(@"BK_USER_BILL_TYPE")
                    && SSJUserChargeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.userId.inTable(@"BK_USER_BILL_TYPE"))
                   || SSJUserBillTypeTable.billId.length() < 4)
               && SSJUserBillTypeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUSERID ()
               && SSJUserChargeTable.operatorType.inTable(@"BK_USER_CHARGE") != 2
               && SSJUserBillTypeTable.billType == type
               && SSJUserChargeTable.fundId == fundId);

    joinClause.join("BK_SHARE_BOOKS_MEMBER", WCDB::JoinClause::Type::Left).
            on(SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJShareBooksMemberTable.booksId.inTable(@"BK_SHARE_BOOKS_MEMBER"));

    WCDB::StatementSelect statementSelect = WCDB::StatementSelect().select(resultList).from(joinClause).
            where(SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER") == SSJShareBooksMemberStateNormal
                  || SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER").isNull()
                  || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"13"
                  || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"14");

    WCTStatement *statement = [db prepare:statementSelect];

    while ([statement step]) {
        currentBalance = (NSNumber *)[statement getValueAtIndex:0];
    }

    return currentBalance;

}


+ (SSJBillingChargeCellItem *)getChargeItemWithStatement:(WCTStatement *)statement {
    SSJBillingChargeCellItem *chargeItem = [[SSJBillingChargeCellItem alloc] init];
    for ( int i = 0 ; i < [statement getCount] ; ++ i ) {
        WCTValue *value = [statement getValueAtIndex:i];
        NSString *name = [statement getNameAtIndex:i];
        NSString *str = SSJUserChargeTable.chargeId.getDescription();
        NSString *tableName = [statement getTableNameAtIndex:i];
        if (value) {

            if ([name isEqualToString:SSJUserChargeTable.chargeId.getDescription()]
                && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.ID = (NSString *)value;
            } else if ([name isEqualToString:SSJUserBillTypeTable.billIcon.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_BILL_TYPE"]) {
                chargeItem.imageName = (NSString *)value;
            } else if ([name isEqualToString:SSJUserBillTypeTable.billName.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_BILL_TYPE"]) {
                chargeItem.typeName = (NSString *)value;
            } else if ([name isEqualToString:SSJUserBillTypeTable.billColor.in(@"BK_USER_BILL_TYPE").getDescription()]
                       && [tableName isEqualToString:@"BK_USER_BILL_TYPE"]) {
                chargeItem.colorValue = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.chargeId.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.incomeOrExpence = [(NSNumber *)value boolValue];
            } else if ([name isEqualToString:SSJUserChargeTable.fundId.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.fundId = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.billDate.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.billDate = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.writeDate.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.editeDate = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.billDate.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.billId = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.memo.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.chargeMemo = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.imgUrl.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.chargeImage = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.thumbUrl.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.chargeThumbImage = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.booksId.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.booksId = (NSString *)value;
            } else if ([name isEqualToString:SSJLoanTable.lender.getDescription()]
                       && [tableName isEqualToString:@"BK_LOAN"]) {
                chargeItem.loanSource = (NSString *)value;
            } else if ([name isEqualToString:SSJLoanTable.type.getDescription()]
                       && [tableName isEqualToString:@"BK_LOAN"]) {
                chargeItem.loanType = (SSJLoanType)[(NSNumber *)value integerValue];
            } else if ([name isEqualToString:SSJUserChargeTable.chargeType.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.idType = (SSJChargeIdType)[(NSNumber *)value integerValue];
            } else if ([name isEqualToString:SSJUserChargeTable.cid.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.sundryId = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.money.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.money = (NSString *)value;
            } else if ([name isEqualToString:SSJUserChargeTable.chargeId.getDescription()]
                       && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.ID = (NSString *)value;
            }
            chargeItem.fundParent = @"3";
            double money = [chargeItem.money doubleValue];
            NSString *moneyStr = [[NSString stringWithFormat:@"%f",money] ssj_moneyDecimalDisplayWithDigits:2];
            if (chargeItem.incomeOrExpence == SSJBillTypePay) {
                chargeItem.money = [NSString stringWithFormat:@"-%@",moneyStr];
            }else if(chargeItem.incomeOrExpence == SSJBillTypeIncome){
                chargeItem.money = [NSString stringWithFormat:@"+%@",moneyStr];
            }
        }
    }
    return chargeItem;
}


@end
