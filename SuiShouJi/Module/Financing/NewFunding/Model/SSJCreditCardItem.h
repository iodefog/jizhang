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

// 信用卡额度
@property(nonatomic) float cardBalance;

// 是否已账单日结算
@property(nonatomic) BOOL settleAtRepaymentDay;

// 账单日
@property(nonatomic) NSInteger cardBillingDay;

// 还款日
@property(nonatomic) NSInteger cardRepaymentDay;

// 信用卡备注
@property(nonatomic, strong) NSString *cardMemo;

// 信用卡颜色
@property(nonatomic, strong) NSString *cardColor;

// 提醒id
@property(nonatomic, strong) NSString *remindId;

// 提醒的状态
@property(nonatomic) BOOL remindState;


@end
