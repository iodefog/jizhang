//
//  SSJFundingTransferListStore.m
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"

@implementation SSJFundingTransferStore
+ (void)queryForFundingTransferListWithSuccess:(void(^)(NSMutableDictionary *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableDictionary *tempdic = [[NSMutableDictionary alloc]init];
        FMResultSet * transferResult = [db executeQuery:@"select substr(a.cbilldate,0,7) as cmonth , a.* , b.cacctname , b.cfundid , b.cicoin , b.operatortype as fundoperatortype , b.cparent from bk_user_charge as a, bk_fund_info as b where a.ibillid in (3,4) and a.operatortype != 2 and a.cuserid = ? and a.ifunsid = b.cfundid and (length(a.loanid) = 0 or a.loanid is null) order by cmonth desc , cwritedate desc , ibillid asc",userid];
        if (!transferResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        NSString *lastDate = @"";
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        while ([transferResult next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.money = [transferResult stringForColumn:@"IMONEY"];
            item.ID = [transferResult stringForColumn:@"ICHARGEID"];
            item.fundId = [transferResult stringForColumn:@"IFUNSID"];
            item.fundImage = [transferResult stringForColumn:@"CICOIN"];
            item.editeDate = [transferResult stringForColumn:@"CWRITEDATE"];
            item.billId = [transferResult stringForColumn:@"IBILLID"];
            item.chargeImage = [transferResult stringForColumn:@"CIMGURL"];
            item.chargeThumbImage = [transferResult stringForColumn:@"THUMBURL"];
            item.chargeMemo = [transferResult stringForColumn:@"CMEMO"];
            item.configId = [transferResult stringForColumn:@"ICONFIGID"];
            item.billDate = [transferResult stringForColumn:@"CBILLDATE"];
            item.fundName = [transferResult stringForColumn:@"CACCTNAME"];
            item.fundOperatorType = [transferResult intForColumn:@"fundoperatortype"];
            item.fundParent = [transferResult stringForColumn:@"cparent"];
            NSString *month = [transferResult stringForColumn:@"cmonth"];
            SSJFundingTransferDetailItem *detailItem = [[SSJFundingTransferDetailItem alloc]init];
            if (tempArr.count == 1) {
                [tempArr addObject:item];
                detailItem = [self transferItemWithArray:tempArr];
                [tempArr removeAllObjects];
            }else{
                [tempArr addObject:item];
            }
            if (![month isEqualToString:lastDate]) {
                if (detailItem.transferInId != nil) {
                    NSMutableArray *monthArr = [NSMutableArray arrayWithArray:@[detailItem]];
                    [tempdic setObject:monthArr forKey:month];
                    lastDate = month;
                }
            }else{
                if (detailItem.transferInId != nil) {
                    [[tempdic objectForKey:month] addObject:detailItem];
                }
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempdic);
            });
        }
    }];
}

+ (SSJFundingTransferDetailItem *)transferItemWithArray:(NSArray <SSJBillingChargeCellItem *>*)array{
    if (array.count != 2) {
        NSLog(@"匹配失败,请检查数据");
        return nil;
    }
    SSJFundingTransferDetailItem *item = [[SSJFundingTransferDetailItem alloc]init];
    SSJBillingChargeCellItem *transferInItem;
    SSJBillingChargeCellItem *transferOutItem;
    for (int i = 0; i < array.count; i ++) {
        SSJBillingChargeCellItem *item = [array ssj_safeObjectAtIndex:i];
        if ([item.billId isEqualToString:@"3"]) {
            transferInItem = [array ssj_safeObjectAtIndex:i];
        }else{
            transferOutItem = [array ssj_safeObjectAtIndex:i];
        }
    }
    if (![transferInItem.billId isEqualToString:@"3"]) {
        NSLog(@"匹配失败,请检查数据");
        return nil;
    }
    if (![transferInItem.money isEqualToString:transferOutItem.money]) {
        NSLog(@"匹配失败,请检查数据");
        return nil;
    }
    if (![transferOutItem.billId isEqualToString:@"4"]) {
        NSLog(@"匹配失败,请检查数据");
        return nil;
    }
    item.transferMoney = transferInItem.money;
    item.transferDate = transferInItem.billDate;
    item.transferInId = transferInItem.fundId;
    item.transferOutId = transferOutItem.fundId;
    item.transferInName = transferInItem.fundName;
    item.transferOutName = transferOutItem.fundName;
    item.transferInImage = transferInItem.fundImage;
    item.transferOutImage = transferOutItem.fundImage;
    item.transferMemo = transferInItem.chargeMemo;
    item.transferInChargeId = transferInItem.ID;
    item.transferOutChargeId = transferOutItem.ID;
    item.transferInFundOperatorType = transferInItem.fundOperatorType;
    item.transferOutFundOperatorType = transferOutItem.fundOperatorType;
    item.editable = YES;
    if ([transferInItem.fundParent isEqualToString:@"11"] || [transferOutItem.fundParent isEqualToString:@"11"]) {
        item.editable = NO;
    }
    if ([transferInItem.fundParent isEqualToString:@"10"] || [transferOutItem.fundParent isEqualToString:@"10"]) {
        item.editable = NO;
    }
    return item;
}

+ (void)deleteFundingTransferWithItem:(SSJFundingTransferDetailItem *)item
                              Success:(void(^)())success
                              failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *userid = SSJUSERID();
        NSString *writeDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 , cwritedate = ? , iversion = ? where ichargeid in (?,?) and cuserid = ?",writeDate,@(SSJSyncVersion()),item.transferInChargeId,item.transferOutChargeId,userid]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            *rollback = YES;
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
    
}

@end
