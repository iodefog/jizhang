//
//  SSJCreditCardStore.h
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJCreditCardItem.h"

@interface SSJCreditCardStore : NSObject

+ (SSJCreditCardItem *)queryCreditCardDetailWithCardId:(NSString *)cardId;

@end
