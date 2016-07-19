//
//  SJJBookKeepingHeader.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJScrollTextView.h"

@interface SSJBookKeepingHeader : UIView


//本月支出
@property(nonatomic,strong)NSString *expenditure;

//本月收入
@property(nonatomic,strong)NSString *income;

@property (strong, nonatomic) UILabel *expenditureTitleLabel;

@property (strong, nonatomic) UILabel *incomeTitleLabel;

@property(nonatomic,strong)SSJScrollTextView *expenditureView;

@property(nonatomic,strong)SSJScrollTextView *incomeView;

//当前月份
@property (nonatomic)long currentMonth;

- (void)updateAfterThemeChange;

@end
