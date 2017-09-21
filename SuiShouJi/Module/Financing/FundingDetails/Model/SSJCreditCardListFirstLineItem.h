//
// Created by ricky on 2017/9/4.
// Copyright (c) 2017 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SSJCreditCardListFirstLineItem : SSJBaseCellItem

@property (nonatomic , copy) NSString *period;

@property (nonatomic , copy) NSString *remainingDaysStr;

@property (nonatomic) double repaymentMoney;

@property (nonatomic) double repaymentForOtherMonth;

@property (nonatomic) double installMoney;

@property (nonatomic) double totalBalance;

@end
