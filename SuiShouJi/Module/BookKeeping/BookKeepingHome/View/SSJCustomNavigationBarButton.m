

//
//  SSJCustomNavigationBarView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCustomNavigationBarButton.h"


@interface SSJCustomNavigationBarButton()
@end

@implementation SSJCustomNavigationBarButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.budgetButton];
    }
    return self;
}

-(void)layoutSubviews{
    self.budgetButton.size = CGSizeMake(self.width, self.height);
    self.budgetButton.leftTop = CGPointMake(0, 0);
}

-(SSJHomeBudgetButton *)budgetButton{
    if (!_budgetButton) {
        _budgetButton = [[SSJHomeBudgetButton alloc]init];
        _budgetButton.budgetButtonClickBlock = ^(SSJBudgetModel *model){
            
        };
    }
    return _budgetButton;
}

-(void)setModel:(SSJBudgetModel *)model{
    _model = model;
    self.budgetButton.model = model;
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
