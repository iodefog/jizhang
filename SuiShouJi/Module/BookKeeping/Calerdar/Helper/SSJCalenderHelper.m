//
//  SSJCalenderHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"

@implementation SSJCalenderHelper
+ (void)queryDataInYear:(NSInteger)year
                          month:(NSInteger)month
                        success:(void (^)(NSDictionary *data))success
                        failure:(void (^)(NSError *error))failure {
    
    if (year == 0 || month > 12) {
        SSJPRINT(@"class:%@\n method:%@\n message:(year == 0 || month > 12)",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        failure(nil);
        return;
    }
    NSString *dateStr = [NSString stringWithFormat:@"%04ld-%02ld-__",year,month];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *resultSet = [db executeQuery:@"select a.*, b.CNAME, b.CCOIN, b.CCOLOR, b.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.CBILLDATE like ? and a.CUSERID = ? and a.OPERATORTYPE <> 2 order by a.CBILLDATE desc", dateStr,userid];
        if (!resultSet) {
            SSJPRINT(@"class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [resultSet boolForColumn:@"ITYPE"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.editeDate = [resultSet stringForColumn:@"CWRITEDATE"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.configId = [resultSet stringForColumn:@"iconfigid"];           if (item.incomeOrExpence && ![item.money hasPrefix:@"-"]) {
                item.money = [NSString stringWithFormat:@"-%@",[resultSet stringForColumn:@"IMONEY"]];
            }else if(!item.incomeOrExpence && ![item.money hasPrefix:@"+"]){
                item.money = [NSString stringWithFormat:@"+%@",[resultSet stringForColumn:@"IMONEY"]];
            }
            NSString *billDate = [resultSet stringForColumn:@"CBILLDATE"];
            if ([result objectForKey:billDate] == nil) {
                NSMutableArray *items = [[NSMutableArray alloc]init];
                [items addObject:item];
                [result setObject:items forKey:billDate];
            }else{
                NSMutableArray *items = [result objectForKey:billDate];
                [items addObject:item];
                [result setObject:items forKey:billDate];
            }
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

@end
