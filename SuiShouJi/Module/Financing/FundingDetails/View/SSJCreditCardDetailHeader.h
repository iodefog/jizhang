//
//  SSJCreditCardDetailHeader.h
//  SuiShouJi
//
//  Created by ricky on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCreditCardItem.h"

@interface SSJCreditCardDetailHeader : UIView

@property(nonatomic, strong) SSJCreditCardItem *item;

@property(nonatomic) double totalIncome;

@property(nonatomic) double totalExpence;

@property(nonatomic, strong) UIView *backGroundView;

@end
