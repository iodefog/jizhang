

//
//  SSJCustomNavigationBarView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCustomNavigationBarView.h"


@interface SSJCustomNavigationBarView()
@end

@implementation SSJCustomNavigationBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:85.0 / 255.0 green:72.0 / 255.0 blue:0 alpha:0.1];
        [self addSubview:self.calenderButton];
        [self addSubview:self.budgetButton];
    }
    return self;
}

-(void)layoutSubviews{
    self.budgetButton.size = CGSizeMake(100, self.height);
    self.budgetButton.leftTop = CGPointMake(0, 0);
    self.calenderButton.right = self.width - 10;
    self.calenderButton.centerY = self.height / 2;
}

-(SSJHomeBarButton *)calenderButton{
    if (!_calenderButton) {
        _calenderButton = [[SSJHomeBarButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    return _calenderButton;
}

-(SSJHomeBudgetButton *)budgetButton{
    if (!_budgetButton) {
        _budgetButton = [[SSJHomeBudgetButton alloc]init];
        [_budgetButton.button addTarget:self action:@selector(budgetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _budgetButton;
}

-(void)setModel:(SSJBudgetModel *)model{
    _model = model;
    self.budgetButton.model = model;
}

-(void)setCurrentDay:(long)currentDay{
    _currentDay = currentDay;
    self.calenderButton.currentDay = _currentDay;
}

-(void)budgetButtonClicked:(id)sender{
    if (self.budgetButtonClickBlock) {
        self.budgetButtonClickBlock(self.model);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
