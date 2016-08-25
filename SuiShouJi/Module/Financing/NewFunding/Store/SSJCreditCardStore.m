//
//  SSJCreditCardStore.m
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardStore.h"
#import "SSJCreditCardItem.h"
#import "SSJDatabaseQueue.h"

@implementation SSJCreditCardStore

+ (SSJCreditCardItem *)queryCreditCardDetailWithCardId:(NSString *)cardId{
    SSJCreditCardItem *item = [[SSJCreditCardItem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select "];
        if (!resultSet) {
            return;
        }
        while([resultSet next]){
            item.cardId = cardId;
            item.cardName = [resultSet stringForColumn:@""];
            item.cardLimit = [resultSet doubleForColumn:@""];
            item.cardBalance = [resultSet doubleForColumn:@""];
            item.settleAtRepaymentDay = [resultSet boolForColumn:@""];
            item.cardBillingDay = [resultSet intForColumn:@""];
            item.cardRepaymentDay = [resultSet intForColumn:@""];
            item.cardMemo = [resultSet stringForColumn:@""];
            item.cardColor = [resultSet stringForColumn:@""];
            item.remindId = [resultSet stringForColumn:@""];
            item.remindState = [resultSet boolForColumn:@""];
        }
    }];
    return item;
}

@end
