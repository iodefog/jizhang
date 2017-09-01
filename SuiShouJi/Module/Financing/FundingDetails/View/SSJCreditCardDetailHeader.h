//
//  SSJCreditCardDetailHeader.h
//  SuiShouJi
//
//  Created by ricky on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingHomeitem.h"
#import "SSJFinancingGradientColorItem.h"

@interface SSJCreditCardDetailHeader : UIView

@property(nonatomic, strong) SSJFinancingHomeitem *item;

@property(nonatomic, strong) UIView *backGroundView;


- (void)updateAfterThemeChange;

@end
