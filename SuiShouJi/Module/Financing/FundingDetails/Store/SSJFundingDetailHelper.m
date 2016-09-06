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
                         success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data))success
                         failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *sql = [NSString stringWithFormat:@"select substr(a.cbilldate,0,7) as cmonth , a.* , a.cwritedate as chargedate , b.*  from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.IFUNSID = '%@' and a.operatortype <> 2 and a.cbilldate <= '%@' order by cmonth desc , a.cbilldate desc ,  a.cwritedate desc", ID , [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
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
            if (item.incomeOrExpence && ![item.money hasPrefix:@"-"]) {
                item.money = [NSString stringWithFormat:@"-%.2f",[item.money doubleValue]];
            }else if(!item.incomeOrExpence && ![item.money hasPrefix:@"+"]){
                item.money = [NSString stringWithFormat:@"+%.2f",[item.money doubleValue]];
            }
            if ([item.typeName isEqualToString:@"转入"]) {
                item.transferSource = [db stringForQuery:@"select b.cacctname from bk_user_charge as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '4' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
            }else if ([item.typeName isEqualToString:@"转出"]){
                item.transferSource = [db stringForQuery:@"select b.cacctname from bk_user_charge as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.cuserid = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '3' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
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
                    [listItem.chargeArray addObject:item];
                }else{
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                    dayItem.date = item.billDate;
                    NSString *incomeSql = [NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a , bk_bill_type as b where ifunsid = '%@' and a.ibillid = b.id and b.itype = 0 and a.cbilldate = '%@' and operatortype <> 2",ID,item.billDate];
                    NSString *expenceSql = [NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a , bk_bill_type as b where ifunsid = '%@' and a.ibillid = b.id and b.itype = 1 and a.cbilldate = '%@' and operatortype <> 2",ID,item.billDate];
                    dayItem.income = [db doubleForQuery:incomeSql];
                    dayItem.expenture = [db doubleForQuery:expenceSql];
                    lastDetailDate = item.billDate;
                    [listItem.chargeArray addObject:dayItem];
                    [listItem.chargeArray addObject:item];
                }
            }else{
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
                NSMutableArray *tempArray = [NSMutableArray array];
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    [tempArray addObject:item];
                }else{
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc]init];
                    dayItem.date = item.billDate;
                    NSString *incomeSql = [NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a , bk_bill_type as b where ifunsid = '%@' and a.ibillid = b.id and b.itype = 0 and a.cbilldate = '%@' and operatortype <> 2",ID,item.billDate];
                    NSString *expenceSql = [NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a , bk_bill_type as b where ifunsid = '%@' and a.ibillid = b.id and b.itype = 1 and a.cbilldate = '%@' and operatortype <> 2",ID,item.billDate];
                    dayItem.income = [db doubleForQuery:incomeSql];
                    dayItem.expenture = [db doubleForQuery:expenceSql];
                    lastDetailDate = item.billDate;
                    [tempArray addObject:dayItem];
                    [tempArray addObject:item];
                }
                listItem.chargeArray = [NSMutableArray arrayWithArray:tempArray];
                lastDate = month;
                [result addObject:listItem];
            }
        }
        
        SSJDispatchMainAsync(^{
            if (success) {
                success(result);
            }
        });
    }];
}

+ (void)queryDataWithCreditCardItem:(SSJCreditCardItem *)cardItem
                        success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data))success
                        failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *sql = [NSString stringWithFormat:@"select a.* , a.cwritedate as chargedate , b.*  from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.IFUNSID = '%@' and a.operatortype <> 2 and a.cbilldate <= '%@' order by a.cbilldate desc ,  a.cwritedate desc", cardItem.cardId , [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
        FMResultSet *resultSet = [db executeQuery:sql];
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
            if (item.incomeOrExpence && ![item.money hasPrefix:@"-"]) {
                item.money = [NSString stringWithFormat:@"-%.2f",[[resultSet stringForColumn:@"IMONEY"] doubleValue]];
            }else if(!item.incomeOrExpence && ![item.money hasPrefix:@"+"]){
                item.money = [NSString stringWithFormat:@"+%.2f",[[resultSet stringForColumn:@"IMONEY"] doubleValue]];
            }
            if ([item.typeName isEqualToString:@"转入"]) {
                item.transferSource = [db stringForQuery:@"select b.cacctname from bk_user_charge as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '4' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
            }else if ([item.typeName isEqualToString:@"转出"]){
                item.transferSource = [db stringForQuery:@"select b.cacctname from bk_user_charge as a, bk_fund_info as b where substr(a.cwritedate,1,19) = ? and a.cuserid = ? and a.ifunsid = b.cfundid and b.cfundid <> ? and a.ibillid = '3' limit 1",[item.editeDate substringWithRange:NSMakeRange(0, 19)],userid,item.fundId];
            }
            NSDate *billDate = [NSDate dateWithString:item.billDate formatString:@"yyyy-MM-dd"];
            NSString *currentPeriod;
            NSString *currentMonth;
            if (billDate.day > cardItem.cardBillingDay) {
                currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",billDate.month,cardItem.cardBillingDay + 1,billDate.month + 1,cardItem.cardBillingDay];
                currentMonth = [[NSDate dateWithYear:billDate.year month:billDate.month + 1 day:billDate.day] formattedDateWithFormat:@"yyyy-MM"];
            }else{
                currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld",billDate.month - 1,cardItem.cardBillingDay + 1,billDate.month,cardItem.cardBillingDay];
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
                if ([lastPeriod isEqualToString:@""]) {
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
        
        SSJDispatchMainAsync(^{
            if (success) {
                success(result);
            }
        });
    }];
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
