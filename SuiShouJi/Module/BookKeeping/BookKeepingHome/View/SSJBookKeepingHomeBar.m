//
//  SSJBookKeepingHomeBar.m
//  SuiShouJi
//
//  Created by ricky on 16/10/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeBar.h"

@implementation SSJBookKeepingHomeBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor];
        [self addSubview:self.budgetButton];
        [self addSubview:self.leftButton];
        [self addSubview:self.rightBarButton];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.budgetButton.centerX = self.width / 2;
    self.budgetButton.bottom = self.height;
    self.leftButton.left = 10;
    self.leftButton.centerY = 10 + self.height / 2;
    self.rightBarButton.right = self.width - 10;
    self.rightBarButton.centerY = 10 + self.height / 2;
}

- (SSJHomeBudgetButton *)budgetButton{
    if (!_budgetButton) {
        _budgetButton = [[SSJHomeBudgetButton alloc]initWithFrame:CGRectMake(0, 0, 200, 46)];
    }
    return _budgetButton;
}

- (SSJBookKeepingHomeBooksButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [[SSJBookKeepingHomeBooksButton alloc]initWithFrame:CGRectMake(0, 0, 30, 32)];
    }
    return _leftButton;
}

- (SSJHomeBarCalenderButton*)rightBarButton{
    if (!_rightBarButton) {
        _rightBarButton = [[SSJHomeBarCalenderButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        //        buttonView.layer.borderColor = [UIColor redColor].CGColor;
        //        buttonView.layer.borderWidth = 1;
    }
    return _rightBarButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
