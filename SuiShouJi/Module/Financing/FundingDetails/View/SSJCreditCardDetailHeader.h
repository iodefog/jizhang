//
//  SSJCreditCardDetailHeader.h
//  SuiShouJi
//
//  Created by ricky on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCreditCardItem.h"
#import "SSJFinancingGradientColorItem.h"

@interface SSJCreditCardDetailHeader : UIView

@property(nonatomic, strong) SSJCreditCardItem *item;

@property(nonatomic) double totalIncome;

@property(nonatomic) double totalExpence;

@property(nonatomic) double cardBalance;

@property(nonatomic, strong) UIView *backGroundView;

@property(nonatomic, strong) SSJFinancingGradientColorItem *colorItem;

- (void)updateAfterThemeChange;

@end
