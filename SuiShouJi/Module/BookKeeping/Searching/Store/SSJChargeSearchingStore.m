//
//  SSJChargeSearchingStore.m
//  SuiShouJi
//
//  Created by ricky on 16/9/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeSearchingStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"

@implementation SSJChargeSearchingStore

+ (void)searchForChargeListWithSearchContent:(NSString *)content
                                   ListOrder:(SSJChargeListOrder)order
                                  Success:(void(^)(NSArray <SSJSearchResultItem *>*result , SSJSearchResultSummaryItem *sumItem))success
                                  failure:(void (^)(NSError *error))failure
{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        SSJSearchHistoryItem *historyItem = [[SSJSearchHistoryItem alloc]init];
        historyItem.searchHistory = content;
        [self saveSearchHistoryItem:historyItem inDatabase:db];
        NSString *userId = SSJUSERID();
        NSString *booksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        if (!booksId.length) {
            booksId = userId;
        }
        NSString *lastBillDate = @"";
        NSString *currentBookId = [db stringForQuery:@"select CCURRENTBOOKSID from bk_user where cuserid = ?",userId];
        NSMutableArray *tempArr = [NSMutableArray array];
        if (!currentBookId.length) {
            currentBookId = userId;
        }
        NSMutableString *sql = [NSMutableString stringWithFormat:@"select a.*, b.cname, b.cicoin, b.ccolor, b.itype from bk_user_charge a, bk_user_bill_type b where a.operatortype <> 2 and a.cbooksid = '%@' and a.ibillid = b.cbillid and a.cuserid = b.cuserid and a.cbooksid = b.cbooksid and (a.cmemo like '%%%@%%' or b.cname like '%%%@%%') and a.cbilldate <= '%@' and a.cbooksid = '%@'", currentBookId, content, content, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"], booksId];
        switch (order) {
            case SSJChargeListOrderMoneyAscending:{
                [sql appendString:@" order by cast(a.imoney as double) asc , a.cbilldate desc"];
                break;
            }
                
            case SSJChargeListOrderMoneyDescending:{
                [sql appendString:@" order by cast(a.imoney as double) desc , a.cbilldate desc"];
                break;
            }
                
            case SSJChargeListOrderDateAscending:{
                [sql appendString:@" order by a.cbilldate asc , cast(a.imoney as double) desc"];
                break;
            }
                
            case SSJChargeListOrderDateDescending:{
                [sql appendString:@" order by a.cbilldate desc , cast(a.imoney as double) desc"];
                break;
            }
                
            default:
                break;  
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
        }
        NSInteger count = 0;
        double income = 0;
        double expenture = 0;
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"cicoin"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            item.incomeOrExpence = [resultSet boolForColumn:@"itype"];
            item.money = [NSString stringWithFormat:@"%.2f",[[resultSet stringForColumn:@"IMONEY"] doubleValue]];
            count ++;
            if (item.incomeOrExpence) {
                expenture =  expenture + [item.money doubleValue];
            }else{
                income =  income +  [item.money doubleValue];
            }
            if (![item.billDate isEqualToString:lastBillDate]) {
                SSJSearchResultItem *searchItem = [[SSJSearchResultItem alloc]init];
                searchItem.searchOrder = order;
                searchItem.date = item.billDate;
                if (order == SSJChargeListOrderDateAscending || order == SSJChargeListOrderDateDescending) {
                    if (item.incomeOrExpence) {
                        searchItem.balance = - [item.money doubleValue];
                    }else{
                        searchItem.balance = [item.money doubleValue];
                    }
                }
                searchItem.chargeList = [NSMutableArray arrayWithObject:item];
                lastBillDate = item.billDate;
                [tempArr addObject:searchItem];
            }else{
                SSJSearchResultItem *searchItem = [tempArr lastObject];
                if (order == SSJChargeListOrderDateAscending || order == SSJChargeListOrderDateDescending) {
                    if (item.incomeOrExpence) {
                        searchItem.balance =  searchItem.balance - [item.money doubleValue];
                    }else{
                        searchItem.balance =  searchItem.balance +  [item.money doubleValue];
                    }
                }
                [searchItem.chargeList addObject:item];
                lastBillDate = item.billDate;
            }
        }
        SSJSearchResultSummaryItem *sumItem = [[SSJSearchResultSummaryItem alloc]init];
        sumItem.resultCount = count;
        sumItem.resultIncome = income;
        sumItem.resultExpenture = expenture;
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArr,sumItem);
            });
        }
    }];
}

+ (void)querySearchHistoryWithSuccess:(void(^)(NSArray <SSJSearchHistoryItem *>*result))success
                                     failure:(void (^)(NSError *error))failure
{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_search_history where cuserid = ? order by csearchdate desc",userId];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
        }
        while ([resultSet next]) {
            SSJSearchHistoryItem *item = [[SSJSearchHistoryItem alloc]init];
            item.searchHistory = [resultSet stringForColumn:@"csearchcontent"];
            item.historyID = [resultSet stringForColumn:@"chistoryid"];
            [tempArr addObject:item];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArr);
            });
        }
    }];
}

+ (NSError *)saveSearchHistoryItem:(SSJSearchHistoryItem *)item
                               inDatabase:(FMDatabase *)db {
    if (!item.historyID.length) {
        item.historyID = SSJUUID();
    }
    NSString *userId = SSJUSERID();
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    if ([db intForQuery:@"select count(1) from bk_search_history where csearchcontent = ? and cuserid = ?",item.searchHistory,userId]) {
        [db executeUpdate:@"update bk_search_history set csearchdate = ? where csearchcontent = ? and cuserid = ?",writeDate,item.searchHistory,userId];
        return nil;
    }
    if (![db executeUpdate:@"insert into bk_search_history (cuserid,csearchcontent,chistoryid,csearchdate) values (?,?,?,?)",userId,item.searchHistory,item.historyID,writeDate]) {
        return [db lastError];
    };
    return nil;
}

+ (BOOL)deleteSearchHistoryItem:(SSJSearchHistoryItem *)item error:(NSError **)error{
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        success = [db executeUpdate:@"delete from bk_search_history where chistoryid = ? and cuserid = ?",item.historyID,userId];
    }];
    return success;
}

+ (BOOL)clearAllSearchHistoryWitherror:(NSError **)error{
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        success = [db executeUpdate:@"delete from bk_search_history where cuserid = ?",userId];
    }];
    return success;
}

@end
