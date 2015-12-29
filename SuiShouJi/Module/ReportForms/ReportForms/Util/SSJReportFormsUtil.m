//
//  SSJReportFormsUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsUtil.h"
#import "SSJReportFormsModel.h"
#import "FMDB.h"

@implementation SSJReportFormsUtil

+ (NSArray *)queryForIncomeInYear:(NSString *)year {
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    NSLog(@"%@",SSJSQLitePath());
    if (![db open]) {
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"SELECT A.AMOUNT, B.CNAME, B.CCOIN, B.CCOLOR FROM (SELECT SUM(IMONEY) AS AMOUNT, IBILLID FROM BK_USER_CHARGE WHERE CBILLDATE LIKE '?年%' GROUP BY IBILLID) AS A, BK_BILL_TYPE AS B WHERE A.IBILLID = B.ID AND B.ITYPE = ?",year,@"0"];
    
//    FMResultSet *resultSet = [db executeQuery:@"SELECT SUM(IMONEY), CNAME, CCOIN, CCOLOR FROM (SELECT A.IMONEY, B.CNAME, B.CCOIN, B.CCOLOR FROM BK_USER_CHARGE AS A, BK_BILL_TYPE AS B WHERE A.IBILLID = B.ID) GROUP BY CNAME"];
    
    if (!resultSet) {
        return nil;
    }
    
    NSMutableArray *result = [@[] mutableCopy];
    while ([resultSet next]) {
        SSJReportFormsModel *item = [[SSJReportFormsModel alloc] init];
//        item.scale = [resultSet doubleForColumn:@""];
        item.money = [resultSet doubleForColumn:@"AMOUNT"];
        item.color = [resultSet stringForColumn:@"CCOLOR"];
        item.imageName = [resultSet stringForColumn:@"CCOIN"];
        item.incomeOrPayName = [resultSet stringForColumn:@"CNAME"];
        [result addObject:item];
    }
    return result;
}

//+ (NSArray *)queryForIncomeInMonth:(NSString *)month {
//    
//}

@end