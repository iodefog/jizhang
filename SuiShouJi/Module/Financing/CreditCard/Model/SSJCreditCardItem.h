//
//  SSJCreditCardItem.h
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
#import "SSJFinancingItem.h"
#import "SSJReminderItem.h"

@interface SSJCreditCardItem : SSJBaseCellItem<SSJFinancingItemProtocol>

/**
 信用卡额度
 */
@property(nonatomic) double cardLimit;

/**
 信用卡收入
 */
@property(nonatomic) double cardIncome;

/**
 信用卡支出
 */
@property(nonatomic) double cardExpence;

/**
 是否已账单日结算
 */
@property(nonatomic) BOOL settleAtRepaymentDay;

/**
 账单日
 */
@property(nonatomic) NSInteger cardBillingDay;

/**
 还款日
 */
@property(nonatomic) NSInteger cardRepaymentDay;


/**
 信用卡颜色
 */
@property(nonatomic, strong) NSString *cardColor;

/**
 信用卡颜色
 */
@property(nonatomic) NSInteger cardOder;

/**
 提醒id
 */
@property(nonatomic, strong) SSJReminderItem *remindItem;

@property(nonatomic) BOOL remindState;

@property(nonatomic, strong) NSString *remindId;

/**
 流水条数
 */
@property(nonatomic) NSInteger chargeCount;

@property(nonatomic) BOOL hasMadeInstalment;


@property(nonatomic) SSJCrediteCardType cardType;


@end
