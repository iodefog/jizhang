//
//  SSJCreditCardItem.h
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJCreditCardItem : SSJBaseCellItem

// 信用卡id
@property(nonatomic, strong) NSString *cardId;

// 信用卡名称
@property(nonatomic, strong) NSString *cardName;

// 信用卡额度
@property(nonatomic) double cardLimit;

// 信用卡额度
@property(nonatomic) double cardBalance;

// 信用卡额度
@property(nonatomic) double cardIncome;

// 信用卡额度
@property(nonatomic) double cardExpence;

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

// 信用卡顺序
@property(nonatomic) NSInteger cardOder;

// 提醒id
@property(nonatomic, strong) NSString *remindId;

// 提醒的状态
@property(nonatomic) BOOL remindState;

// 信用卡流水
@property(nonatomic) NSInteger chargeCount;

//渐变的开始颜色
@property(nonatomic, strong) NSString *startColor;

//渐变的结束颜色
@property(nonatomic, strong) NSString *endColor;

@property(nonatomic) BOOL hasMadeInstalment;

@property(nonatomic) SSJCrediteCardType cardType;

@end
