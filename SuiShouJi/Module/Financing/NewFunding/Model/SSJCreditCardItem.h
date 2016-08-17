//
//  SSJCreditCardItem.h
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJCreditCardItem : SSJBaseItem

// 信用卡id
@property(nonatomic, strong) NSString *cardId;

// 信用卡名称
@property(nonatomic, strong) NSString *cardName;

// 信用卡额度
@property(nonatomic) float cardLimit;

// 账单日
@property(nonatomic, strong) NSString *cardBillingDate;

// 还款日
@property(nonatomic, strong) NSString *cardRepaymentDate;

// 还款日离账单日日期
@property(nonatomic) NSInteger cardAddDate;

// 信用卡备注
@property(nonatomic, strong) NSString *cardMemo;

@end
