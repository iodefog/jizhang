//
//  SSJCreditCardStore.m
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJCreditCardStore

+ (SSJCreditCardItem *)queryCreditCardDetailWithCardId:(NSString *)cardId{
    SSJCreditCardItem *item = [[SSJCreditCardItem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        FMResultSet *resultSet = [db executeQuery:@"select a.* , b.istate , c.ccolor , c.cmemo , c.cacctname , d.iblance from bk_user_credit a , bk_user_remind b , bk_fund_info c , bk_funs_acct d where a.cfundid = ? and a.cfundid = c.cfundid and a.cuserid = ? and a.cremindid = b.cremindid a.cfundid = d.cfundid",cardId,userId];
        if (!resultSet) {
            return;
        }
        while([resultSet next]){
            item.cardId = cardId;
            item.cardName = [resultSet stringForColumn:@"cremindid"];
            item.cardLimit = [resultSet doubleForColumn:@"iquota"];
            item.cardBalance = [resultSet doubleForColumn:@"iblance"];
            item.settleAtRepaymentDay = [resultSet boolForColumn:@"cmemo"];
            item.cardBillingDay = [resultSet intForColumn:@"cbilldate"];
            item.cardRepaymentDay = [resultSet intForColumn:@"crepaymentdate"];
            item.cardMemo = [resultSet stringForColumn:@"cmemo"];
            item.cardColor = [resultSet stringForColumn:@"ccolor"];
            item.remindId = [resultSet stringForColumn:@"cremindid"];
            item.remindState = [resultSet boolForColumn:@"istate"];
        }
    }];
    return item;
}

@end
