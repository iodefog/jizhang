//
//  SSJFundingDetailHeader.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingGradientColorItem.h"

@interface SSJFundingDetailHeader : UIView

@property(nonatomic) double income;

@property(nonatomic) double expence;

@property(nonatomic, strong) SSJFinancingGradientColorItem *item;

@end
