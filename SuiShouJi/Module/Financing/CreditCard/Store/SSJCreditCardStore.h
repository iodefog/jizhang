//
//  SSJCreditCardStore.h
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJCreditCardItem.h"
#import "SSJDatabaseQueue.h"

@interface SSJCreditCardStore : NSObject

+ (SSJCreditCardItem *)queryCreditCardDetailWithCardId:(NSString *)cardId;

+ (NSError *)saveCreditCardWithCardItem:(SSJCreditCardItem *)item
                             inDatabase:(FMDatabase *)db;
@end
